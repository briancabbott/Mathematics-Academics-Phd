
let rec sepConcat sep sl =
  match sl with
  | [] -> ""
  | h::t ->
      let f a x = a ^ (sep ^ x) in
      let base = h in let l = t in List.fold_left f base l;;

let pipe fs =
  let f a x n = x (a n) in let base n = n in List.fold_left f base fs;;

let stringOfList f l = "[" ^ ((sepConcat "; " (List.map f l)) ^ "]");;

let rec clone x n = pipe stringOfList x n;;
