module Zip
  @[Link("c")]
  lib C
    fun fdopen(fd : LibC::Int, mode : UInt8*) : LibZip::File*
    fun dup(fd : LibC::Int) : LibC::Int
  end

  @[Link(ldflags: "-lzip")]
  lib LibZip
    alias Int16T = LibC::Short
    alias Int32T = LibC::Int
    alias Int64T = LibC::Long
    alias Int8T = LibC::Char
    alias TimeT = LibC::Long
    alias Uint16T = LibC::UShort
    alias Uint32T = LibC::UInt
    alias Uint64T = LibC::ULong
    alias Uint8T = UInt8
    alias IoCodecvt = Void
    alias IoLockT = Void
    alias IoMarker = Void
    alias IoWideData = Void
    alias Off64T = LibC::Long
    alias OffT = LibC::Long
    alias ZipCancelCallback = (ZipT, Void* -> LibC::Int)
    alias ZipFile = Void
    alias ZipFlagsT = ZipUint32T
    alias ZipInt16T = Int16T
    alias ZipInt32T = Int32T
    alias ZipInt64T = Int64T
    alias ZipInt8T = Int8T
    alias ZipProgressCallback = (ZipT, LibC::Double, Void* -> Void)
    alias ZipProgressCallbackT = (LibC::Double -> Void)
    alias ZipSource = Void
    alias ZipSourceCallback = (Void*, Void*, ZipUint64T, ZipSourceCmdT -> ZipInt64T)
    alias ZipUint16T = Uint16T
    alias ZipUint32T = Uint32T
    alias ZipUint64T = Uint64T
    alias ZipUint8T = Uint8T

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

    fun zip_add(x0 : ZipT, x1 : LibC::Char*, x2 : ZipSourceT) : ZipInt64T
    fun zip_add_dir(x0 : ZipT, x1 : LibC::Char*) : ZipInt64T
    fun zip_archive_set_tempdir(x0 : ZipT, x1 : LibC::Char*) : LibC::Int
    fun zip_close(x0 : ZipT) : LibC::Int
    fun zip_compression_method_supported(method : ZipInt32T, compress : LibC::Int) : LibC::Int
    fun zip_delete(x0 : ZipT, x1 : ZipUint64T) : LibC::Int
    fun zip_dir_add(x0 : ZipT, x1 : LibC::Char*, x2 : ZipFlagsT) : ZipInt64T
    fun zip_discard(x0 : ZipT)
    fun zip_encryption_method_supported(method : ZipUint16T, encode : LibC::Int) : LibC::Int
    fun zip_error_clear(x0 : ZipT)
    fun zip_error_code_system(x0 : ZipError*) : LibC::Int
    fun zip_error_code_zip(x0 : ZipError*) : LibC::Int
    fun zip_error_fini(x0 : ZipError*)
    fun zip_error_get(x0 : ZipT, x1 : LibC::Int*, x2 : LibC::Int*)
    fun zip_error_get_sys_type(x0 : LibC::Int) : LibC::Int
    fun zip_error_init(x0 : ZipError*)
    fun zip_error_init_with_code(x0 : ZipError*, x1 : LibC::Int)
    fun zip_error_set(x0 : ZipError*, x1 : LibC::Int, x2 : LibC::Int)
    fun zip_error_strerror(x0 : ZipError*) : LibC::Char*
    fun zip_error_system_type(x0 : ZipError*) : LibC::Int
    fun zip_error_to_data(x0 : ZipError*, x1 : Void*, x2 : ZipUint64T) : ZipInt64T
    fun zip_error_to_str(x0 : LibC::Char*, x1 : ZipUint64T, x2 : LibC::Int, x3 : LibC::Int) : LibC::Int
    fun zip_fclose(x0 : ZipFileT) : LibC::Int
    fun zip_fdopen(x0 : LibC::Int, x1 : LibC::Int, x2 : LibC::Int*) : ZipT
    fun zip_file_add(x0 : ZipT, x1 : LibC::Char*, x2 : ZipSourceT, x3 : ZipFlagsT) : ZipInt64T
    fun zip_file_attributes_init(x0 : ZipFileAttributes*)
    fun zip_file_error_clear(x0 : ZipFileT)
    fun zip_file_error_get(x0 : ZipFileT, x1 : LibC::Int*, x2 : LibC::Int*)
    fun zip_file_extra_field_delete(x0 : ZipT, x1 : ZipUint64T, x2 : ZipUint16T, x3 : ZipFlagsT) : LibC::Int
    fun zip_file_extra_field_delete_by_id(x0 : ZipT, x1 : ZipUint64T, x2 : ZipUint16T, x3 : ZipUint16T, x4 : ZipFlagsT) : LibC::Int
    fun zip_file_extra_field_get(x0 : ZipT, x1 : ZipUint64T, x2 : ZipUint16T, x3 : ZipUint16T*, x4 : ZipUint16T*, x5 : ZipFlagsT) : ZipUint8T*
    fun zip_file_extra_field_get_by_id(x0 : ZipT, x1 : ZipUint64T, x2 : ZipUint16T, x3 : ZipUint16T, x4 : ZipUint16T*, x5 : ZipFlagsT) : ZipUint8T*
    fun zip_file_extra_field_set(x0 : ZipT, x1 : ZipUint64T, x2 : ZipUint16T, x3 : ZipUint16T, x4 : ZipUint8T*, x5 : ZipUint16T, x6 : ZipFlagsT) : LibC::Int
    fun zip_file_extra_fields_count(x0 : ZipT, x1 : ZipUint64T, x2 : ZipFlagsT) : ZipInt16T
    fun zip_file_extra_fields_count_by_id(x0 : ZipT, x1 : ZipUint64T, x2 : ZipUint16T, x3 : ZipFlagsT) : ZipInt16T
    fun zip_file_get_comment(x0 : ZipT, x1 : ZipUint64T, x2 : ZipUint32T*, x3 : ZipFlagsT) : LibC::Char*
    fun zip_file_get_error(x0 : ZipFileT) : ZipError*
    fun zip_file_get_external_attributes(x0 : ZipT, x1 : ZipUint64T, x2 : ZipFlagsT, x3 : ZipUint8T*, x4 : ZipUint32T*) : LibC::Int
    fun zip_file_rename(x0 : ZipT, x1 : ZipUint64T, x2 : LibC::Char*, x3 : ZipFlagsT) : LibC::Int
    fun zip_file_replace(x0 : ZipT, x1 : ZipUint64T, x2 : ZipSourceT, x3 : ZipFlagsT) : LibC::Int
    fun zip_file_set_comment(x0 : ZipT, x1 : ZipUint64T, x2 : LibC::Char*, x3 : ZipUint16T, x4 : ZipFlagsT) : LibC::Int
    fun zip_file_set_dostime(x0 : ZipT, x1 : ZipUint64T, x2 : ZipUint16T, x3 : ZipUint16T, x4 : ZipFlagsT) : LibC::Int
    fun zip_file_set_encryption(x0 : ZipT, x1 : ZipUint64T, x2 : ZipUint16T, x3 : LibC::Char*) : LibC::Int
    fun zip_file_set_external_attributes(x0 : ZipT, x1 : ZipUint64T, x2 : ZipFlagsT, x3 : ZipUint8T, x4 : ZipUint32T) : LibC::Int
    fun zip_file_set_mtime(x0 : ZipT, x1 : ZipUint64T, x2 : TimeT, x3 : ZipFlagsT) : LibC::Int
    fun zip_file_strerror(x0 : ZipFileT) : LibC::Char*
    fun zip_fopen(x0 : ZipT, x1 : LibC::Char*, x2 : ZipFlagsT) : ZipFileT
    fun zip_fopen_encrypted(x0 : ZipT, x1 : LibC::Char*, x2 : ZipFlagsT, x3 : LibC::Char*) : ZipFileT
    fun zip_fopen_index(x0 : ZipT, x1 : ZipUint64T, x2 : ZipFlagsT) : ZipFileT
    fun zip_fopen_index_encrypted(x0 : ZipT, x1 : ZipUint64T, x2 : ZipFlagsT, x3 : LibC::Char*) : ZipFileT
    fun zip_fread(x0 : ZipFileT, x1 : Void*, x2 : ZipUint64T) : ZipInt64T
    fun zip_fseek(x0 : ZipFileT, x1 : ZipInt64T, x2 : LibC::Int) : ZipInt8T
    fun zip_ftell(x0 : ZipFileT) : ZipInt64T
    fun zip_get_archive_comment(x0 : ZipT, x1 : LibC::Int*, x2 : ZipFlagsT) : LibC::Char*
    fun zip_get_archive_flag(x0 : ZipT, x1 : ZipFlagsT, x2 : ZipFlagsT) : LibC::Int
    fun zip_get_error(x0 : ZipT) : ZipError*
    fun zip_get_file_comment(x0 : ZipT, x1 : ZipUint64T, x2 : LibC::Int*, x3 : LibC::Int) : LibC::Char*
    fun zip_get_name(x0 : ZipT, x1 : ZipUint64T, x2 : ZipFlagsT) : LibC::Char*
    fun zip_get_num_entries(x0 : ZipT, x1 : ZipFlagsT) : ZipInt64T
    fun zip_get_num_files(x0 : ZipT) : LibC::Int
    fun zip_libzip_version : LibC::Char*
    fun zip_name_locate(x0 : ZipT, x1 : LibC::Char*, x2 : ZipFlagsT) : ZipInt64T
    fun zip_open(x0 : LibC::Char*, x1 : LibC::Int, x2 : LibC::Int*) : ZipT
    fun zip_open_from_source(x0 : ZipSourceT, x1 : LibC::Int, x2 : ZipError*) : ZipT
    fun zip_register_cancel_callback_with_state(x0 : ZipT, x1 : ZipCancelCallback, x2 : (Void* -> Void), x3 : Void*) : LibC::Int
    fun zip_register_progress_callback(x0 : ZipT, x1 : ZipProgressCallbackT)
    fun zip_register_progress_callback_with_state(x0 : ZipT, x1 : LibC::Double, x2 : ZipProgressCallback, x3 : (Void* -> Void), x4 : Void*) : LibC::Int
    fun zip_rename(x0 : ZipT, x1 : ZipUint64T, x2 : LibC::Char*) : LibC::Int
    fun zip_replace(x0 : ZipT, x1 : ZipUint64T, x2 : ZipSourceT) : LibC::Int
    fun zip_set_archive_comment(x0 : ZipT, x1 : LibC::Char*, x2 : ZipUint16T) : LibC::Int
    fun zip_set_archive_flag(x0 : ZipT, x1 : ZipFlagsT, x2 : LibC::Int) : LibC::Int
    fun zip_set_default_password(x0 : ZipT, x1 : LibC::Char*) : LibC::Int
    fun zip_set_file_comment(x0 : ZipT, x1 : ZipUint64T, x2 : LibC::Char*, x3 : LibC::Int) : LibC::Int
    fun zip_set_file_compression(x0 : ZipT, x1 : ZipUint64T, x2 : ZipInt32T, x3 : ZipUint32T) : LibC::Int
    fun zip_source_begin_write(x0 : ZipSourceT) : LibC::Int
    fun zip_source_begin_write_cloning(x0 : ZipSourceT, x1 : ZipUint64T) : LibC::Int
    fun zip_source_buffer(x0 : ZipT, x1 : Void*, x2 : ZipUint64T, x3 : LibC::Int) : ZipSourceT
    fun zip_source_buffer_create(x0 : Void*, x1 : ZipUint64T, x2 : LibC::Int, x3 : ZipError*) : ZipSourceT
    fun zip_source_buffer_fragment(x0 : ZipT, x1 : ZipBufferFragment*, x2 : ZipUint64T, x3 : LibC::Int) : ZipSourceT
    fun zip_source_buffer_fragment_create(x0 : ZipBufferFragment*, x1 : ZipUint64T, x2 : LibC::Int, x3 : ZipError*) : ZipSourceT
    fun zip_source_close(x0 : ZipSourceT) : LibC::Int
    fun zip_source_commit_write(x0 : ZipSourceT) : LibC::Int
    fun zip_source_error(x0 : ZipSourceT) : ZipError*
    fun zip_source_file(x0 : ZipT, x1 : LibC::Char*, x2 : ZipUint64T, x3 : ZipInt64T) : ZipSourceT
    fun zip_source_file_create(x0 : LibC::Char*, x1 : ZipUint64T, x2 : ZipInt64T, x3 : ZipError*) : ZipSourceT
    fun zip_source_filep(x0 : ZipT, x1 : File*, x2 : ZipUint64T, x3 : ZipInt64T) : ZipSourceT
    fun zip_source_filep_create(x0 : File*, x1 : ZipUint64T, x2 : ZipInt64T, x3 : ZipError*) : ZipSourceT
    fun zip_source_free(x0 : ZipSourceT)
    fun zip_source_function(x0 : ZipT, x1 : ZipSourceCallback, x2 : Void*) : ZipSourceT
    fun zip_source_function_create(x0 : ZipSourceCallback, x1 : Void*, x2 : ZipError*) : ZipSourceT
    fun zip_source_get_file_attributes(x0 : ZipSourceT, x1 : ZipFileAttributes*) : LibC::Int
    fun zip_source_is_deleted(x0 : ZipSourceT) : LibC::Int
    fun zip_source_keep(x0 : ZipSourceT)
    fun zip_source_make_command_bitmap(x0 : ZipSourceCmdT, ...) : ZipInt64T
    fun zip_source_open(x0 : ZipSourceT) : LibC::Int
    fun zip_source_read(x0 : ZipSourceT, x1 : Void*, x2 : ZipUint64T) : ZipInt64T
    fun zip_source_rollback_write(x0 : ZipSourceT)
    fun zip_source_seek(x0 : ZipSourceT, x1 : ZipInt64T, x2 : LibC::Int) : LibC::Int
    fun zip_source_seek_compute_offset(x0 : ZipUint64T, x1 : ZipUint64T, x2 : Void*, x3 : ZipUint64T, x4 : ZipError*) : ZipInt64T
    fun zip_source_seek_write(x0 : ZipSourceT, x1 : ZipInt64T, x2 : LibC::Int) : LibC::Int
    fun zip_source_stat(x0 : ZipSourceT, x1 : ZipStatT*) : LibC::Int
    fun zip_source_tell(x0 : ZipSourceT) : ZipInt64T
    fun zip_source_tell_write(x0 : ZipSourceT) : ZipInt64T
    fun zip_source_write(x0 : ZipSourceT, x1 : Void*, x2 : ZipUint64T) : ZipInt64T
    fun zip_source_zip(x0 : ZipT, x1 : ZipT, x2 : ZipUint64T, x3 : ZipFlagsT, x4 : ZipUint64T, x5 : ZipInt64T) : ZipSourceT
    fun zip_stat(x0 : ZipT, x1 : LibC::Char*, x2 : ZipFlagsT, x3 : ZipStatT*) : LibC::Int
    fun zip_stat_index(x0 : ZipT, x1 : ZipUint64T, x2 : ZipFlagsT, x3 : ZipStatT*) : LibC::Int
    fun zip_stat_init(x0 : ZipStatT*)
    fun zip_strerror(x0 : ZipT) : LibC::Char*
    fun zip_unchange(x0 : ZipT, x1 : ZipUint64T) : LibC::Int
    fun zip_unchange_all(x0 : ZipT) : LibC::Int
    fun zip_unchange_archive(x0 : ZipT) : LibC::Int

    struct File
      _flags : LibC::Int
      _io_read_ptr : LibC::Char*
      _io_read_end : LibC::Char*
      _io_read_base : LibC::Char*
      _io_write_base : LibC::Char*
      _io_write_ptr : LibC::Char*
      _io_write_end : LibC::Char*
      _io_buf_base : LibC::Char*
      _io_buf_end : LibC::Char*
      _io_save_base : LibC::Char*
      _io_backup_base : LibC::Char*
      _io_save_end : LibC::Char*
      _markers : IoMarker*
      _chain : File*
      _fileno : LibC::Int
      _flags2 : LibC::Int
      _old_offset : OffT
      _cur_column : LibC::UShort
      _vtable_offset : LibC::Char
      _shortbuf : LibC::Char[1]
      _lock : IoLockT*
      _offset : Off64T
      _codecvt : IoCodecvt*
      _wide_data : IoWideData*
      _freeres_list : File*
      _freeres_buf : Void*
      __pad5 : LibC::SizeT
      _mode : LibC::Int
      _unused2 : LibC::Char[20]
    end

    struct ZipBufferFragment
      data : ZipUint8T*
      length : ZipUint64T
    end

    struct ZipError
      zip_err : LibC::Int
      sys_err : LibC::Int
      str : LibC::Char*
    end

    struct ZipFileAttributes
      valid : ZipUint64T
      version : ZipUint8T
      host_system : ZipUint8T
      ascii : ZipUint8T
      version_needed : ZipUint8T
      external_file_attributes : ZipUint32T
      general_purpose_bit_flags : ZipUint16T
      general_purpose_bit_mask : ZipUint16T
    end

    struct ZipSourceArgsSeek
      offset : ZipInt64T
      whence : LibC::Int
    end

    struct ZipStat
      valid : ZipUint64T             # which fields have valid values
      name : LibC::Char*             # name of the file
      index : ZipUint64T             # index within archive
      size : ZipUint64T              # size of file (uncompressed)
      comp_size : ZipUint64T         # size of file (compressed)
      mtime : TimeT                  # modification time
      crc : ZipUint32T               # crc of file data
      comp_method : ZipUint16T       # compression method used
      encryption_method : ZipUint16T # encryption method used
      flags : ZipUint32T             # reserved for future use
    end

    type ZipFileT = Void*
    type ZipSourceCmdT = ZipSourceCmd
    type ZipSourceT = Void*
    type ZipStatT = ZipStat
    type ZipT = Void*

    # type ZipArchive = UInt8*
    # type ZipFile = UInt8*
    # type ZipSource = UInt8*
    # alias ZipError = Int32
  end
end
