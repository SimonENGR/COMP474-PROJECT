(deftemplate user-profile
   (slot name)
   (slot age (type INTEGER))
   (slot risk-tolerance (allowed-values low medium high))
   (slot capital (type NUMBER)))

(deftemplate recommendation
   (slot recipient)
   (slot advice-type)
   (slot message))

(deftemplate asset-class
   (slot type)
   (slot description)
   (slot risk-level (allowed-values low medium high extreme))
   (slot avg-return (type NUMBER)))

(deffacts initial-knowledge
   (user-profile (name "Lance") (age 22) (risk-tolerance high) (capital 5000.0))
   (user-profile (name "Agatha") (age 60) (risk-tolerance low) (capital 150000.0))
   (user-profile (name "Lorelei") (age 35) (risk-tolerance medium) (capital 25000.0))
   (user-profile (name "Karen") (age 17) (risk-tolerance low) (capital 500.0)) 
   (user-profile (name "Steven") (age 45) (risk-tolerance high) (capital 1000000.0))
   (asset-class (type "Individual-Stocks") (description "Shares in specific companies") (risk-level high) (avg-return 0.10))
   (asset-class (type "Diversified-ETF") (description "Basket of stocks/bonds, auto-diversified") (risk-level medium) (avg-return 0.07))
   (asset-class (type "Bonds") (description "Corporate or Gov debt, fixed income") (risk-level low) (avg-return 0.04))
   (asset-class (type "GIC") (description "Guaranteed Investment Certificate, locked-in safe return") (risk-level low) (avg-return 0.045))
   (asset-class (type "Cash") (description "High interest savings, instant liquidity") (risk-level low) (avg-return 0.02))
   (asset-class (type "Gold") (description "Precious metal, hedge against inflation") (risk-level medium) (avg-return 0.05))
   (asset-class (type "Crypto") (description "Digital currency, speculative and volatile") (risk-level extreme) (avg-return 0.60)))