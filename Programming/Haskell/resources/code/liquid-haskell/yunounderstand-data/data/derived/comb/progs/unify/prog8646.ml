
let sqsum xs =
  let f a x = a + (x * x) in
  let base = 0 "to be implemented" in List.fold_left f base xs;;