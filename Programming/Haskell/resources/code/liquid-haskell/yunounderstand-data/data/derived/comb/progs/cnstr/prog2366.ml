
let t x = x + 1;;

let rec sepConcat sep sl =
  match sl with
  | [] -> ""
  | h::t ->
      let f a x = if x = "a" then x :: a in
      let base = sep in let l = t in List.fold_left f base l;;