
let pipe fs = let f a x = x fs in let base x = x in List.fold_left f base fs;;