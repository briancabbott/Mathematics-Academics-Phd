
let rec digitsOfInt n =
  if n <= 0
  then []
  else List.rev ((n mod 10) :: (List.rev (digitsOfInt (n / 10))));;

let rec sumList xs =
  match xs with | [] -> 0 | h::t -> h + (sumList t) | _ -> (-1);;

let x = [];;

let rec additivePersistence n =
  if (sumList (digitsOfInt n)) > 9
  then
    ((print_string "going into then") / (print_newline ());
     1
     ::
     x;
     additivePersistence (sumList (digitsOfInt n)))
  else (1 :: x; sumList x);;
