
let pipe fs = let f a x a = x a in let base = [] in List.fold_left f base fs;;