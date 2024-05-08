
let pipe fs =
  let f a x = match x with | [] -> 0 | _ -> 1 in
  let base = 0 in List.fold_left f base fs;;

let _ = pipe [(fun x  -> x + 3); (fun x  -> x + x)] 3;;