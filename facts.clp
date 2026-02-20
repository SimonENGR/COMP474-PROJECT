;;; Template
(deftemplate user-profile
   (slot name)
   (slot age    (type INTEGER))
   (slot risk-tolerance (allowed-values low medium high))
   (slot capital (type NUMBER))
   ;; default -1 is used if the user is unsure, in this case it will use 65-age to estimate time horizon
   (slot horizon (type INTEGER) (default -1)))

(deftemplate recommendation
   (slot recipient)
   (slot advice-type)
   (slot message))

(deftemplate asset-class
   (slot type)
   (slot description)
   (slot risk-level  (allowed-values low medium high))
   (slot avg-return  (type NUMBER)))

;;; Knowledge Base
(deffacts asset-types
   (asset-class
      (type "Individual-Stocks")
      (description "Shares in companies")
      (risk-level high) (avg-return 0.10))

   (asset-class
      (type "Diversified-ETF")
      (description "Passive index fund for large diversification")
      (risk-level medium) (avg-return 0.07))

   (asset-class
      (type "Corporate-Bonds")
      (description "Corporate debt higher yield since there's a default risk")
      (risk-level medium) (avg-return 0.05))

   (asset-class
      (type "Government-Bonds")
      (description "Gov debt, no risk but lower returns than Corp bond")
      (risk-level low) (avg-return 0.03))

   (asset-class
      (type "GIC")
      (description "Guaranteed Investment Certificate for safe return")
      (risk-level low) (avg-return 0.045))

   (asset-class
      (type "Cash")
      (description "Cash will be stored in High Interest Saving Accounts, lowest return but liquid")
      (risk-level low) (avg-return 0.02))

   (asset-class
      (type "Gold")
      (description "Inflation hedge, used for diversification")
      (risk-level medium) (avg-return 0.05))

   (asset-class
      (type "Real-Estate-REIT")
      (description "Real Estate Investment Trust, provides income-generating assets")
      (risk-level medium) (avg-return 0.06))

   (asset-class
      (type "High-Yield-Bonds")
      (description "Low quality bonds; high risk but higher yield")
      (risk-level high) (avg-return 0.07))

   (asset-class
      (type "Emerging-Markets-ETF")
      (description "Developing nations stocks; high volatility with high growth potential")
      (risk-level high) (avg-return 0.09))
)
