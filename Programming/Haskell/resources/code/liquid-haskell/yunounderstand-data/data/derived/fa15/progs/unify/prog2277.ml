
let stringOfList f l =
  let fx a b = a ^ b in let base = "" in List.fold_left fx base l;;

let _ = stringOfList string_of_int [1; 2; 3; 4; 5; 6];;