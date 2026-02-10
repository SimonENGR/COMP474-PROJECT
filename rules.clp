;;; Low/Mid High Growth
(defrule aggressive-growth-strategy
   "High Risk + Young (< 30)"
   (user-profile (name ?n) (age ?a) (risk-tolerance high))
   (test (< ?a 30))
   =>
   (assert (recommendation (recipient ?n) 
                           (advice-type "Aggressive Growth") 
                           (message "50% Individual Stocks / 30% ETFs / 20% Crypto"))))

(defrule balanced-strategy
   "Medium Risk"
   (user-profile (name ?n) (risk-tolerance medium))
   =>
   (assert (recommendation (recipient ?n) 
                           (advice-type "Balanced") 
                           (message "60% Diversified ETF / 30% Bonds / 10% Gold"))))

(defrule conservative-strategy
   "Low Risk"
   (user-profile (name ?n) (risk-tolerance low))
   =>
   (assert (recommendation (recipient ?n) 
                           (advice-type "Preservation") 
                           (message "50% GIC / 40% Bonds / 10% Cash"))))

;;; Edge Cases

(defrule check-min-capital
   "Capital < 1000: Recommend Cash/GIC only"
   (user-profile (name ?n) (capital ?c))
   (test (< ?c 1000.0))
   =>
   (assert (recommendation (recipient ?n) 
                           (advice-type "Warning") 
                           (message "Capital low. Stick to Cash or flexible GICs to avoid fees."))))

(defrule high-net-worth-hedge
   "Capital > 1M: Suggest Gold/Alternatives"
   (user-profile (name ?n) (capital ?c))
   (test (>= ?c 1000000.0))
   =>
   (assert (recommendation (recipient ?n) 
                           (advice-type "Wealth Management") 
                           (message "Consider allocating 5-10% to Gold as a hedge against volatility."))))

(defrule pre-retirement
   "Age > 55: Shift to Income"
   (user-profile (name ?n) (age ?a))
   (test (> ?a 55))
   =>
   (assert (recommendation (recipient ?n) 
                           (advice-type "Shift to Income") 
                           (message "Move 10% of portfolio from Stocks to GICs annually."))))

(defrule minor-account
   "Under 18 Check"
   (user-profile (name ?n) (age ?a))
   (test (< ?a 18))
   =>
   (printout t "!! NOTICE: User " ?n " is a minor. Custodial account required." crlf))

;;; --- EXPLANATION & OUTPUT RULES ---

(defrule explain-crypto-risk
   "Context rule: If Crypto is recommended, warn about risk"
   (recommendation (advice-type "Aggressive Growth"))
   (asset-class (type "Crypto") (risk-level ?r))
   =>
   (printout t "   (NOTE: You have been recommended Crypto. Be aware this is " ?r " risk.)" crlf))

(defrule print-recommendation
   (recommendation (recipient ?n) (advice-type ?t) (message ?m))
   =>
   (printout t ">> ADVICE FOR " ?n ": " ?t " -- " ?m crlf))

(defrule cleanup-recommendations
   (declare (salience -10))
   ?f <- (recommendation)
   =>
   (retract ?f))