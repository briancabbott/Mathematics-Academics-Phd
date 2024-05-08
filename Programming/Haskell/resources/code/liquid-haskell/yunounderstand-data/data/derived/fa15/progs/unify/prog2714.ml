
let pipe fs =
  let f a x = let h::t = fs in h a in
  let base = 0 in List.fold_left f base fs;;

let _ = pipe [(fun x  -> x + x); (fun x  -> x + 3)] 3;;