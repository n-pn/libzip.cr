@[Link(ldflags: "-lzip")]
lib LibZip
  ZIP_CHECKCONS          =     4
  ZIP_CM_BZIP2           =    12
  ZIP_CM_DEFAULT         =    -1
  ZIP_CM_DEFLATE         =     8
  ZIP_CM_DEFLATE64       =     9
  ZIP_CM_IMPLODE         =     6
  ZIP_CM_JPEG            =    96
  ZIP_CM_LZ77            =    19
  ZIP_CM_LZMA            =    14
  ZIP_CM_LZMA2           =    33
  ZIP_CM_PKWARE_IMPLODE  =    10
  ZIP_CM_PPMD            =    98
  ZIP_CM_REDUCE_1        =     2
  ZIP_CM_REDUCE_2        =     3
  ZIP_CM_REDUCE_3        =     4
  ZIP_CM_REDUCE_4        =     5
  ZIP_CM_SHRINK          =     1
  ZIP_CM_STORE           =     0
  ZIP_CM_TERSE           =    18
  ZIP_CM_WAVPACK         =    97
  ZIP_CM_XZ              =    95
  ZIP_CM_ZSTD            =    93
  ZIP_CREATE             =     1
  ZIP_EM_AES_128         =   257
  ZIP_EM_AES_192         =   258
  ZIP_EM_AES_256         =   259
  ZIP_EM_NONE            =     0
  ZIP_EM_TRAD_PKWARE     =     1
  ZIP_EM_UNKNOWN         = 65535
  ZIP_ER_CANCELLED       =    32
  ZIP_ER_CHANGED         =    15
  ZIP_ER_CLOSE           =     3
  ZIP_ER_COMPNOTSUPP     =    16
  ZIP_ER_COMPRESSED_DATA =    31
  ZIP_ER_CRC             =     7
  ZIP_ER_DELETED         =    23
  ZIP_ER_ENCRNOTSUPP     =    24
  ZIP_ER_EOF             =    17
  ZIP_ER_EXISTS          =    10
  ZIP_ER_INCONS          =    21
  ZIP_ER_INTERNAL        =    20
  ZIP_ER_INUSE           =    29
  ZIP_ER_INVAL           =    18
  ZIP_ER_MEMORY          =    14
  ZIP_ER_MULTIDISK       =     1
  ZIP_ER_NOENT           =     9
  ZIP_ER_NOPASSWD        =    26
  ZIP_ER_NOZIP           =    19
  ZIP_ER_OK              =     0
  ZIP_ER_OPEN            =    11
  ZIP_ER_OPNOTSUPP       =    28
  ZIP_ER_RDONLY          =    25
  ZIP_ER_READ            =     5
  ZIP_ER_REMOVE          =    22
  ZIP_ER_RENAME          =     2
  ZIP_ER_SEEK            =     4
  ZIP_ER_TELL            =    30
  ZIP_ER_TMPOPEN         =    12
  ZIP_ER_WRITE           =     6
  ZIP_ER_WRONGPASSWD     =    27
  ZIP_ER_ZIPCLOSED       =     8
  ZIP_ER_ZLIB            =    13
  ZIP_ET_LIBZIP          =     3
  ZIP_ET_NONE            =     0
  ZIP_ET_SYS             =     1
  ZIP_ET_ZLIB            =     2
  ZIP_EXCL               =     2
  ZIP_INT16_MAX          = 32767
  ZIP_INT8_MAX           =   127
  ZIP_RDONLY             =    16
  ZIP_TRUNCATE           =     8
  ZIP_UINT16_MAX         = 65535
  ZIP_UINT8_MAX          =   255

  alias File = Void
  alias Flags = UInt32T
  alias String = LibC::Char*

  alias Int16T = LibC::Short
  alias Int32T = LibC::Int
  alias Int64T = LibC::Long
  alias Int8T = LibC::Char
  alias TimeT = LibC::Long
  alias Uint16T = LibC::UShort
  alias UInt32T = LibC::UInt
  alias UInt64T = LibC::ULong
  alias Uint8T = UInt8

  alias ZipCancelCallback = (ZipT, Void* -> LibC::Int)

  alias ProgressCallback = (ZipT, LibC::Double, Void* -> Void)
  alias ProgressCallbackT = (LibC::Double -> Void)

  alias ZipSource = Void
  alias ZipSourceCallback = (Void*, Void*, UInt64T, ZipSourceCmdT -> Int64T)

  enum ZipSourceCmd
    ZipSourceOpen              =  0
    ZipSourceRead              =  1
    ZipSourceClose             =  2
    ZipSourceStat              =  3
    ZipSourceError             =  4
    ZipSourceFree              =  5
    ZipSourceSeek              =  6
    ZipSourceTell              =  7
    ZipSourceBeginWrite        =  8
    ZipSourceCommitWrite       =  9
    ZipSourceRollbackWrite     = 10
    ZipSourceWrite             = 11
    ZipSourceSeekWrite         = 12
    ZipSourceTellWrite         = 13
    ZipSourceSupports          = 14
    ZipSourceRemove            = 15
    ZipSourceReserved1         = 16
    ZipSourceBeginWriteCloning = 17
    ZipSourceAcceptEmpty       = 18
    ZipSourceGetFileAttributes = 19
  end

  fun zip_add(archive : ZipT, x1 : String, x2 : ZipSourceT) : Int64T
  fun zip_add_dir(archive : ZipT, x1 : String) : Int64T
  fun zip_close(archive : ZipT) : LibC::Int
  fun zip_compression_method_supported(method : Int32T, compress : LibC::Int) : LibC::Int
  fun zip_delete(archive : ZipT, x1 : UInt64T) : LibC::Int
  fun zip_dir_add(archive : ZipT, x1 : String, x2 : Flags) : Int64T
  fun zip_discard(archive : ZipT)
  fun zip_encryption_method_supported(method : Uint16T, encode : LibC::Int) : LibC::Int
  fun zip_error_clear(archive : ZipT)
  fun zip_error_code_system(x0 : ZipErrorT*) : LibC::Int
  fun zip_error_code_zip(x0 : ZipErrorT*) : LibC::Int
  fun zip_error_fini(x0 : ZipErrorT*)
  fun zip_error_get(archive : ZipT, x1 : LibC::Int*, x2 : LibC::Int*)
  fun zip_error_get_sys_type(x0 : LibC::Int) : LibC::Int
  fun zip_error_init(x0 : ZipErrorT*)
  fun zip_error_init_with_code(x0 : ZipErrorT*, x1 : LibC::Int)
  fun zip_error_set(x0 : ZipErrorT*, x1 : LibC::Int, x2 : LibC::Int)
  fun zip_error_strerror(x0 : ZipErrorT*) : String
  fun zip_error_system_type(x0 : ZipErrorT*) : LibC::Int
  fun zip_error_to_data(x0 : ZipErrorT*, x1 : Void*, x2 : UInt64T) : Int64T
  fun zip_error_to_str(x0 : String, x1 : UInt64T, x2 : LibC::Int, x3 : LibC::Int) : LibC::Int
  fun zip_fclose(file : ZipFileT) : LibC::Int
  fun zip_fdopen(x0 : LibC::Int, x1 : LibC::Int, x2 : LibC::Int*) : ZipT
  fun zip_file_add(archive : ZipT, name : String, source : ZipSourceT, flags : Flags) : Int64T
  fun zip_file_attributes_init(x0 : ZipFileAttributesT*)
  fun zip_file_error_clear(file : ZipFileT)
  fun zip_file_error_get(file : ZipFileT, x1 : LibC::Int*, x2 : LibC::Int*)
  fun zip_file_extra_field_delete(archive : ZipT, x1 : UInt64T, x2 : Uint16T, x3 : Flags) : LibC::Int
  fun zip_file_extra_field_delete_by_id(archive : ZipT, x1 : UInt64T, x2 : Uint16T, x3 : Uint16T, x4 : Flags) : LibC::Int
  fun zip_file_extra_field_get(archive : ZipT, x1 : UInt64T, x2 : Uint16T, x3 : Uint16T*, x4 : Uint16T*, x5 : Flags) : Uint8T*
  fun zip_file_extra_field_get_by_id(archive : ZipT, x1 : UInt64T, x2 : Uint16T, x3 : Uint16T, x4 : Uint16T*, x5 : Flags) : Uint8T*
  fun zip_file_extra_field_set(archive : ZipT, x1 : UInt64T, x2 : Uint16T, x3 : Uint16T, x4 : Uint8T*, x5 : Uint16T, x6 : Flags) : LibC::Int
  fun zip_file_extra_fields_count(archive : ZipT, x1 : UInt64T, x2 : Flags) : Int16T
  fun zip_file_extra_fields_count_by_id(archive : ZipT, x1 : UInt64T, x2 : Uint16T, x3 : Flags) : Int16T
  fun zip_file_get_comment(archive : ZipT, x1 : UInt64T, x2 : UInt32T*, x3 : Flags) : String
  fun zip_file_get_error(file : ZipFileT) : ZipErrorT*
  fun zip_file_get_external_attributes(archive : ZipT, x1 : UInt64T, x2 : Flags, x3 : Uint8T*, x4 : UInt32T*) : LibC::Int
  fun zip_file_is_seekable(file : ZipFileT) : LibC::Int
  fun zip_file_rename(archive : ZipT, x1 : UInt64T, x2 : String, x3 : Flags) : LibC::Int
  fun zip_file_replace(archive : ZipT, x1 : UInt64T, x2 : ZipSourceT, x3 : Flags) : LibC::Int
  fun zip_file_set_comment(archive : ZipT, x1 : UInt64T, x2 : String, x3 : Uint16T, x4 : Flags) : LibC::Int
  fun zip_file_set_dostime(archive : ZipT, x1 : UInt64T, x2 : Uint16T, x3 : Uint16T, x4 : Flags) : LibC::Int
  fun zip_file_set_encryption(archive : ZipT, x1 : UInt64T, x2 : Uint16T, x3 : String) : LibC::Int
  fun zip_file_set_external_attributes(archive : ZipT, x1 : UInt64T, x2 : Flags, x3 : Uint8T, x4 : UInt32T) : LibC::Int
  fun zip_file_set_mtime(archive : ZipT, x1 : UInt64T, mtime : TimeT, x3 : Flags) : LibC::Int
  fun zip_file_strerror(file : ZipFileT) : String
  fun zip_fopen(archive : ZipT, x1 : String, x2 : Flags) : ZipFileT
  fun zip_fopen_encrypted(archive : ZipT, x1 : String, x2 : Flags, x3 : String) : ZipFileT
  fun zip_fopen_index(archive : ZipT, x1 : UInt64T, x2 : Flags) : ZipFileT
  fun zip_fopen_index_encrypted(archive : ZipT, x1 : UInt64T, x2 : Flags, x3 : String) : ZipFileT
  fun zip_fread(file : ZipFileT, x1 : Void*, x2 : UInt64T) : Int64T
  fun zip_fseek(file : ZipFileT, x1 : Int64T, x2 : LibC::Int) : Int8T
  fun zip_ftell(file : ZipFileT) : Int64T
  fun zip_get_archive_comment(archive : ZipT, x1 : LibC::Int*, x2 : Flags) : String
  fun zip_get_archive_flag(archive : ZipT, x1 : Flags, x2 : Flags) : LibC::Int
  fun zip_get_error(archive : ZipT) : ZipErrorT*
  fun zip_get_file_comment(archive : ZipT, x1 : UInt64T, x2 : LibC::Int*, x3 : LibC::Int) : String
  fun zip_get_name(archive : ZipT, x1 : UInt64T, x2 : Flags) : String
  fun zip_get_num_entries(archive : ZipT, x1 : Flags) : Int64T
  fun zip_get_num_files(archive : ZipT) : LibC::Int
  fun zip_libzip_version : String
  fun zip_name_locate(archive : ZipT, x1 : String, x2 : Flags) : Int64T
  fun zip_open(x0 : String, x1 : LibC::Int, x2 : LibC::Int*) : ZipT
  fun zip_open_from_source(x0 : ZipSourceT, x1 : LibC::Int, x2 : ZipErrorT*) : ZipT
  fun zip_register_cancel_callback_with_state(archive : ZipT, x1 : ZipCancelCallback, x2 : (Void* -> Void), x3 : Void*) : LibC::Int
  fun zip_register_progress_callback(archive : ZipT, x1 : ProgressCallbackT)

  fun zip_register_progress_callback_with_state(archive : ZipT, x1 : LibC::Double, x2 : ProgressCallback, x3 : (Void* -> Void), x4 : Void*) : LibC::Int
  fun zip_rename(archive : ZipT, x1 : UInt64T, x2 : String) : LibC::Int
  fun zip_replace(archive : ZipT, x1 : UInt64T, x2 : ZipSourceT) : LibC::Int
  fun zip_set_archive_comment(archive : ZipT, x1 : String, x2 : Uint16T) : LibC::Int
  fun zip_set_archive_flag(archive : ZipT, x1 : Flags, x2 : LibC::Int) : LibC::Int
  fun zip_set_default_password(archive : ZipT, x1 : String) : LibC::Int
  fun zip_set_file_comment(archive : ZipT, x1 : UInt64T, x2 : String, len : LibC::Int) : LibC::Int
  fun zip_set_file_compression(archive : ZipT, index : UInt64T, comp : Int32T, comp_flags : UInt32T) : LibC::Int
  fun zip_source_begin_write(x0 : ZipSourceT) : LibC::Int
  fun zip_source_begin_write_cloning(x0 : ZipSourceT, x1 : UInt64T) : LibC::Int
  fun zip_source_buffer(archive : ZipT, x1 : Void*, x2 : UInt64T, x3 : LibC::Int) : ZipSourceT
  fun zip_source_buffer_create(x0 : Void*, x1 : UInt64T, x2 : LibC::Int, x3 : ZipErrorT*) : ZipSourceT
  fun zip_source_buffer_fragment(archive : ZipT, x1 : ZipBufferFragmentT*, x2 : UInt64T, x3 : LibC::Int) : ZipSourceT
  fun zip_source_buffer_fragment_create(x0 : ZipBufferFragmentT*, x1 : UInt64T, x2 : LibC::Int, x3 : ZipErrorT*) : ZipSourceT
  fun zip_source_close(x0 : ZipSourceT) : LibC::Int
  fun zip_source_commit_write(x0 : ZipSourceT) : LibC::Int
  fun zip_source_error(x0 : ZipSourceT) : ZipErrorT*
  fun zip_source_file(archive : ZipT, fname : String, start : UInt64T, len : Int64T) : ZipSourceT
  fun zip_source_file_create(x0 : String, x1 : UInt64T, x2 : Int64T, x3 : ZipErrorT*) : ZipSourceT
  fun zip_source_filep(archive : ZipT, x1 : File*, x2 : UInt64T, x3 : Int64T) : ZipSourceT
  fun zip_source_filep_create(x0 : File*, x1 : UInt64T, x2 : Int64T, x3 : ZipErrorT*) : ZipSourceT
  fun zip_source_free(x0 : ZipSourceT)
  fun zip_source_function(archive : ZipT, x1 : ZipSourceCallback, x2 : Void*) : ZipSourceT
  fun zip_source_function_create(x0 : ZipSourceCallback, x1 : Void*, x2 : ZipErrorT*) : ZipSourceT
  fun zip_source_get_file_attributes(x0 : ZipSourceT, x1 : ZipFileAttributesT*) : LibC::Int
  fun zip_source_is_deleted(x0 : ZipSourceT) : LibC::Int
  fun zip_source_keep(x0 : ZipSourceT)
  fun zip_source_make_command_bitmap(x0 : ZipSourceCmdT, ...) : Int64T
  fun zip_source_open(x0 : ZipSourceT) : LibC::Int
  fun zip_source_read(x0 : ZipSourceT, x1 : Void*, x2 : UInt64T) : Int64T
  fun zip_source_rollback_write(x0 : ZipSourceT)
  fun zip_source_seek(x0 : ZipSourceT, x1 : Int64T, x2 : LibC::Int) : LibC::Int
  fun zip_source_seek_compute_offset(x0 : UInt64T, x1 : UInt64T, x2 : Void*, x3 : UInt64T, x4 : ZipErrorT*) : Int64T
  fun zip_source_seek_write(x0 : ZipSourceT, x1 : Int64T, x2 : LibC::Int) : LibC::Int
  fun zip_source_stat(x0 : ZipSourceT, x1 : ZipStatT*) : LibC::Int
  fun zip_source_tell(x0 : ZipSourceT) : Int64T
  fun zip_source_tell_write(x0 : ZipSourceT) : Int64T
  fun zip_source_window_create(x0 : ZipSourceT, x1 : UInt64T, x2 : Int64T, x3 : ZipErrorT*) : ZipSourceT
  fun zip_source_write(x0 : ZipSourceT, x1 : Void*, x2 : UInt64T) : Int64T
  fun zip_source_zip(archive : ZipT, x1 : ZipT, x2 : UInt64T, x3 : Flags, x4 : UInt64T, x5 : Int64T) : ZipSourceT
  fun zip_source_zip_create(archive : ZipT, x1 : UInt64T, x2 : Flags, x3 : UInt64T, x4 : Int64T, x5 : ZipErrorT*) : ZipSourceT
  fun zip_stat(archive : ZipT, x1 : String, x2 : Flags, x3 : ZipStatT*) : LibC::Int
  fun zip_stat_index(archive : ZipT, x1 : UInt64T, x2 : Flags, x3 : ZipStatT*) : LibC::Int
  fun zip_stat_init(stat : ZipStatT*)
  fun zip_strerror(archive : ZipT) : String
  fun zip_unchange(archive : ZipT, x1 : UInt64T) : LibC::Int
  fun zip_unchange_all(archive : ZipT) : LibC::Int
  fun zip_unchange_archive(archive : ZipT) : LibC::Int

  struct ZipBufferFragment
    data : Uint8T*
    length : UInt64T
  end

  struct ZipError
    zip_err : LibC::Int
    sys_err : LibC::Int
    str : String
  end

  struct ZipFileAttributes
    valid : UInt64T
    version : Uint8T
    host_system : Uint8T
    ascii : Uint8T
    version_needed : Uint8T
    external_file_attributes : UInt32T
    general_purpose_bit_flags : Uint16T
    general_purpose_bit_mask : Uint16T
  end

  struct ZipSourceArgsSeek
    offset : Int64T
    whence : LibC::Int
  end

  struct ZipStat
    valid : UInt64T
    name : String
    index : UInt64T
    size : UInt64T
    comp_size : UInt64T
    mtime : TimeT
    crc : UInt32T
    comp_method : Uint16T
    encryption_method : Uint16T
    flags : UInt32T
  end

  type ZipBufferFragmentT = ZipBufferFragment
  type ZipErrorT = ZipError
  type ZipFileAttributesT = ZipFileAttributes
  type ZipFileT = File*
  type ZipSourceCmdT = ZipSourceCmd
  type ZipSourceT = Void*
  type ZipStatT = ZipStat
  type ZipT = Void*
end
