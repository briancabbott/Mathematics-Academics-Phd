



Include higher_order 




map' (+3) [1,5,3,1,6]
map' (++ "|") ["BIFF", "BANG", "POW"]
map' (replicate 3) [3..6]
map' (map' (^2)) [ [1,2], [3,4,5,6], [7,8] ]


filter (>3) [1,5,3,2,1,6,4,3,2,1]
filter (==3) [1,2,3,4,5]
filter even [1..10]
let notNull x = not (null x) in filter notNull [[1,2,3], [], [3,4,5], [2,2], [], [], []]
filter (`elem` ['a'..'z') "u LaUgh aT mE BeCaUsE I aM diFfeRent"
filter (`elem` ['A'..'Z']) "i LAuGh at you bEcause u R all the same"
filter (<15) (filter even [1..20])
-- same as [x | x <- [1..20], x < 15, even x]

