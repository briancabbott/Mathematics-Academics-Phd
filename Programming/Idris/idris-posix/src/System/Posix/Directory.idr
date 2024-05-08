module System.Posix.Directory

%include C "dirent_accessors.c"
%include C "stat_wrappers.c"
%include C "getcwd_wrapper.c"
%include C "create_dir_wrappers.c"

opendir : String -> IO Ptr
opendir s = foreign FFI_C "opendir" (String -> IO Ptr) s

closedir : Ptr -> IO ()
closedir p = foreign FFI_C "closedir" (Ptr -> IO Unit) p

readdir : Ptr -> IO Ptr
readdir p = foreign FFI_C "readdir" (Ptr -> IO Ptr) p

dirent_d_name : Ptr -> IO String
dirent_d_name p = foreign FFI_C "idris_posix_dirent_d_name" (Ptr -> IO String) p

getDirectoryContents : String -> IO (List String)
getDirectoryContents s = do
    d <- opendir s
    c <- f d []
    closedir d
    pure (reverse c)
  where f : Ptr -> List String -> IO (List String)
        f d xs = do
            c <- readdir d
            n <- nullPtr c
            if n
            then pure xs
            else do
              n <- dirent_d_name c
              f d (n :: xs)

export
doesFileExist : String -> IO Bool
doesFileExist s = map (/= 0) (foreign FFI_C "idris_posix_is_file" (String -> IO Int) s)

export
doesDirectoryExist : String -> IO Bool
doesDirectoryExist s = map (/= 0) (foreign FFI_C "idris_posix_is_directory" (String -> IO Int) s)

||| Calls `getcwd` to get the current directory
export
getCurrentDirectory : IO String
getCurrentDirectory = foreign FFI_C "idris_getcwd" (IO String)

||| Create a new directory at this path
||| NOTE that this currently does not perform error checking!
export
createDirectory : String -> IO ()
createDirectory str = foreign FFI_C "idris_create_dir" (String -> IO Int) str *> pure ()
