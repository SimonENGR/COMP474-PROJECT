;;; Note for salience usage
;;; To make sure that the rules trigger in the proper 
;;; Only 3 rules use salience
;;; get user @ 10 so its used first
;;; infer horizon @ 5 so its used second
;;; everything else has salience 0 so it runs third
;;; User input

(defrule get-user-profile
   "Prompt user for information when starting"
   (declare (salience 10))
   =>
   (printout t "Enter your first name (Example \"Simon\"): ")
   (bind ?name (read))
   
   (printout t "Enter your age (Example 25): ")
   (bind ?age (read))
   
   (printout t "Enter your risk tolerance (Here the system expects \"low\", \"medium\", or \"high\"): ")
   (bind ?risk (read))
   
   (printout t "Enter the money you wish to invest (The system expects a value): ")
   (bind ?capital (read))
   
   (printout t "Enter investment horizon in years (or -1 if you are not sure): ")
   (bind ?horizon (read))
   
   (assert (user-profile (name ?name)
                         (age ?age)
                         (risk-tolerance ?risk)
                         (capital ?capital)
                         (horizon ?horizon))))


;;; Rule to estimate horizon from age (in case the user was not sure about time horizon and wrote -1)

(defrule infer-horizon-from-age
   "If the user is unsure about horizon, estimate it by 65-age (retirement)."
   (declare (salience 5))
   ?p <- (user-profile (horizon -1) (age ?a))
   =>
   (bind ?inferred (max 0 (- 65 ?a)))
   (modify ?p (horizon ?inferred)))


;;; Investment strategy rules
;;; Since my investment advice ranges from least aggressive to most aggressive
;;; (1) Capital Preservation (2) Safe-Mid Growth (3) Mid Growth (4) Aggressive-Mid Growth (5) Aggressive Growth
;;; The rules below looks at every scenario (a tree graph is visible in the power point to visually see my recommendation)

;;; (1) Capital Preservation
(defrule capital-preservation-strategy
   "Strategy for low risk with less than 5 years OR any risk with less than 3 years"
   (user-profile (name ?n) (risk-tolerance ?r) (horizon ?h))
   (test (or (and (eq ?r low) (<= ?h 5))
             (< ?h 3)))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Capital Preservation")
      (message "50% Gov Bonds / 30% GIC / 20% Cash | ~2.9% return. A short horizon (less than 3 years) or low risk with less 5 years demands principal protection above all else [Stanyer 2014; Thau 2010]."))))

;;; (2) Safe-Mid Growth
(defrule safe-mid-growth-strategy
   "Strategy for low risk with more than 5 years OR medium risk between 3 years and 5 years"

   (user-profile (name ?n) (risk-tolerance ?r) (horizon ?h))
   (test (or (and (eq ?r low) (> ?h 5))
             (and (eq ?r medium) (>= ?h 3) (<= ?h 5))))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Safe Mid Growth")
      (message "20% ETF / 35% Gov Bonds / 15% Corp Bonds / 20% GIC / 10% Cash | ~3.8% return. Modest equity allocation, position to have a little bit more return with small risk [Stanyer 2014; Fabozzi & Markowitz 2011]."))))

;;; (3) Mid Growth
(defrule mid-growth-strategy
   "Strategy for medium risk and 5-10 years OR High risk and 3-5 years"
   (user-profile (name ?n) (risk-tolerance ?r) (horizon ?h))
   (test (or (and (eq ?r medium) (> ?h 5) (<= ?h 10))
             (and (eq ?r high) (>= ?h 3) (<= ?h 5))))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Mid Growth")
      (message "50% ETF / 30% Gov Bonds / 10% Corp Bonds / 10% Cash | ~5.0% return. Balanced allocation between risk and reward [Stanyer 2014; Fabozzi & Markowitz 2011; Thau 2010]."))))

;;; (4) Aggressive-Mid Growth
(defrule aggressive-mid-growth-strategy
   "Strategy for medium risk when holding for more than 10 years OR High risk when holding for 5-10 years"
   (user-profile (name ?n) (risk-tolerance ?r) (horizon ?h))
   (test (or (and (eq ?r medium) (> ?h 10))
             (and (eq ?r high) (> ?h 5) (<= ?h 10))))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Aggressive Mid Growth")
      (message "60% Stocks / 20% ETF / 10% Corp Bonds / 10% Gold | ~7.5% return. Time allows recovery from negative return years [Stanyer 2014; Fabozzi & Markowitz 2011]."))))

;;; (5) Aggressive Growth
(defrule aggressive-growth-strategy
   "Strategy 5 - High risk and >10 years only"
   (user-profile (name ?n) (risk-tolerance high) (horizon ?h))
   (test (> ?h 10))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Aggressive Growth")
      (message "75% Stocks / 15% Emerging-Markets / 5% Gov Bonds / 5% Gold | ~8.5% return. Maximum stock exposure means high risk but also highest potential returns [Stanyer 2014; Fabozzi & Markowitz 2011]."))))


;;; Rules for edge cases
(defrule check-min-capital
   "Not enough money to invest"
   (user-profile (name ?n) (capital ?c))
   (test (< ?c 1000.0))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Warning: Low Capital")
      (message "Capital less than 1000. We recommend to use a high interest saving account or a flexible GIC only.[Stanyer 2014; Thau 2010]."))))

(defrule emergency-fund-check
   "Not enough money for an emergency fund, needs more before investing."
   (user-profile (name ?n) (capital ?c))
   (test (and (>= ?c 1000.0) (< ?c 6000.0)))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Emergency Fund Advisory")
      (message "Capital less than 1000 $. We recommend to have 3-6 months of living expenses before investing [Stanyer 2014; Thau 2010]."))))

(defrule high-net-worth-hedge
   "At a high net worth, make sure to have sufficient gold allocation as an inflation hedge"
   (user-profile (name ?n) (capital ?c))
   (test (>= ?c 1000000.0))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Wealth Management Note")
      (message "Portfolio over 1 million, having 5-10% in Gold to fight inflation [Fabozzi & Markowitz 2011]."))))

(defrule approaching-withdrawal-shift
   "Low time horizon (3-10 years), Lower risk portfolio preferable"
   (user-profile (name ?n) (horizon ?h))
   (test (and (>= ?h 3) (<= ?h 10)))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Approaching Withdrawal Shift")
      (message "Horizon is 3-10 years away, transition stock position to government bonds or GICs annually to reduce risk [Stanyer 2014; Thau 2010]."))))

(defrule inflation-risk-warning
   "Conservative strategy mixed with a long time horizon (over 10 years) results in inflation risk."
   (user-profile (name ?n) (horizon ?h))
   (test (> ?h 10))
   (recommendation (recipient ?n) (advice-type ?t))
   (test (or (eq ?t "Capital Preservation") (eq ?t "Safe Mid Growth")))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Inflation Risk Warning")
      (message "Your conservative allocation is at risk of losing value due to inflation over a very long time horizon. Real returns will be low in high-inflation periods [Stanyer 2014; Fabozzi & Markowitz 2011]."))))

;;; Horizon Explanations
(defrule investment-horizon-short
   "Short Horizon(less than 3 years)"
   (user-profile (name ?n) (horizon ?h))
   (test (and (>= ?h 0) (< ?h 3)))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Investment Horizon: Short")
      (message "Horizon is short (less than 3 years). Capital preservation and income generation is more important than growth [Fabozzi & Markowitz 2011]."))))

(defrule investment-horizon-medium
   "Medium Horizon(between 3 and 5 years)"
   (user-profile (name ?n) (horizon ?h))
   (test (and (>= ?h 3) (<= ?h 5)))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Investment Horizon: Medium")
      (message "Horizon is medium (3-5 years). A mix of growth and safety is appropriate [Fabozzi & Markowitz 2011]."))))

(defrule investment-horizon-long
   "Long Horizon(between 6 and 10 years)"
   (user-profile (name ?n) (horizon ?h))
   (test (and (> ?h 5) (<= ?h 10)))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Investment Horizon: Long")
      (message "Horizon is long (6-10 years). A balanced mix is appropriate but more risk will bring higher returns [Fabozzi & Markowitz 2011]."))))

(defrule investment-horizon-very-long
   "Very Long Horizon (Over 10 years)"
   (user-profile (name ?n) (horizon ?h))
   (test (> ?h 10))
   =>
   (assert (recommendation (recipient ?n)
      (advice-type "Investment Horizon: Very Long")
      (message "Horizon is very long (over 10 years). Since time is on  your side, volatility is safe and compounding is very likely [Fabozzi & Markowitz 2011; Stanyer 2014]."))))


;;; Asset class rules
(defrule explain-individual-stocks
   "Explain Individual Stocks."
   (recommendation (message ?msg))
   (asset-class (type "Individual-Stocks") (risk-level ?r) (avg-return ?ret))
   (test (str-index "Stocks" ?msg))
   =>
   (printout t "    [Asset] Individual-Stocks | risk=" ?r " | avg-return=" ?ret
               " | Highest risk and highest return." crlf))

(defrule explain-diversified-etf
   "Explain Diversified ETF."
   (recommendation (message ?msg))
   (asset-class (type "Diversified-ETF") (risk-level ?r) (avg-return ?ret))
   (test (str-index "ETF" ?msg))
   =>
   (printout t "    [Asset] Diversified-ETF | risk=" ?r " | avg-return=" ?ret
               " | Good balance of growth and risk compared to individual stocks." crlf))

(defrule explain-government-bonds
   "Explain Government Bonds."
   (recommendation (message ?msg))
   (asset-class (type "Government-Bonds") (risk-level ?r) (avg-return ?ret))
   (test (str-index "Gov Bonds" ?msg))
   =>
   (printout t "    [Asset] Government-Bonds | risk=" ?r " | avg-return=" ?ret
               " | No credit risk but bond with lowest return." crlf))

(defrule explain-corporate-bonds
   "Explain Corporate Bonds."
   (recommendation (message ?msg))
   (asset-class (type "Corporate-Bonds") (risk-level ?r) (avg-return ?ret))
   (test (str-index "Corp Bonds" ?msg))
   =>
   (printout t "    [Asset] Corporate-Bonds | risk=" ?r " | avg-return=" ?ret
               " | Yield spread compensates for default risk." crlf))

(defrule explain-gic
   "Explain GIC."
   (recommendation (message ?msg))
   (asset-class (type "GIC") (risk-level ?r) (avg-return ?ret))
   (test (str-index "GIC" ?msg))
   =>
   (printout t "    [Asset] GIC | risk=" ?r " | avg-return=" ?ret
               " | Principal-guaranteed, locked-in return, improve stability of the portfolio." crlf))

(defrule explain-cash
   "Explain Cash and HISA."
   (recommendation (message ?msg))
   (asset-class (type "Cash") (risk-level ?r) (avg-return ?ret))
   (test (str-index "Cash" ?msg))
   =>
   (printout t "    [Asset] Cash/HISA | risk=" ?r " | avg-return=" ?ret
               " | Maximum liquidity but lowest return and risk inflation." crlf))

(defrule explain-gold
   "Explain Gold."
   (recommendation (message ?msg))
   (asset-class (type "Gold") (risk-level ?r) (avg-return ?ret))
   (test (str-index "Gold" ?msg))
   =>
   (printout t "    [Asset] Gold | risk=" ?r " | avg-return=" ?ret
               " | Inflation hedge." crlf))

(defrule explain-real-estate-reit
   "Explain REITs."
   (recommendation (message ?msg))
   (asset-class (type "Real-Estate-REIT") (risk-level ?r) (avg-return ?ret))
   (test (str-index "REITs" ?msg))
   =>
   (printout t "    [Asset] Real-Estate-REIT | risk=" ?r " | avg-return=" ?ret
               " | Income-generating asset." crlf))

(defrule explain-high-yield-bonds
   "Explain High-Yield Bonds."
   (recommendation (message ?msg))
   (asset-class (type "High-Yield-Bonds") (risk-level ?r) (avg-return ?ret))
   (test (str-index "High-Yield-Bonds" ?msg))
   =>
   (printout t "    [Asset] High-Yield-Bonds | risk=" ?r " | avg-return=" ?ret
               " | High credit risk for higher yield." crlf))

(defrule explain-emerging-markets-etf
   "Explain Emerging Markets ETF."
   (recommendation (message ?msg))
   (asset-class (type "Emerging-Markets-ETF") (risk-level ?r) (avg-return ?ret))
   (test (str-index "Emerging-Markets" ?msg))
   =>
   (printout t "    [Asset] Emerging-Markets-ETF | risk=" ?r " | avg-return=" ?ret
               " | High volatility, high growth potential." crlf))


;;; Output
(defrule print-recommendation
   "Print recommendation to console."
   (recommendation (recipient ?n) (advice-type ?t) (message ?m))
   =>
   (printout t crlf ">> Advice for " ?n ":" crlf)
   (printout t "   Strategy : " ?t crlf)
   (printout t "   Details  : " ?m crlf))
