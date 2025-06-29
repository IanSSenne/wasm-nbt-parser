;; nbt parser by FetchBot (Ian Senne)
(module
	(import "env" "push_byte" (func $push_byte (param i32)))
	(import "env" "push_short" (func $push_short (param i32)))
	(import "env" "push_int" (func $push_int (param i32)))
	(import "env" "push_long" (func $push_long (param i64)))
	(import "env" "push_float" (func $push_float (param f32)))
	(import "env" "push_double" (func $push_double (param f64)))
	(import "env" "push_byte_array" (func $push_byte_array (param i32 i32)))
	(import "env" "push_string" (func $push_string (param i32 i32)))
	(import "env" "push_list" (func $push_list (param i32)))
	(import "env" "push_compound" (func $push_compound (param i32 i32 i32)))
	(import "env" "push_int_array" (func $push_int_array (param i32 i32)))
	(import "env" "push_long_array" (func $push_long_array (param i32 i32)))
	(memory $mem 0)
	(export "memory" (memory $mem))
	(global $index (mut i32) (i32.const 0))
	(global $root (mut i32) (i32.const 0))
	(global $is_le (mut i32) (i32.const 1))
	(export "index" (global $index))
	(export "le" (global $is_le))
	(func $inc
		(global.get $index)
		i32.const 1
		i32.add
		(global.set $index)
	)
	(func $incn (param $n i32)
		(global.get $index)
		local.get $n
		i32.add
		(global.set $index)
	)
	(func $load16 (param $idx i32) (result i32)
		global.get $is_le
		if
			local.get $idx
			i32.load16_s
			return
		end
		local.get $idx
		i32.load8_u
		i32.const 8
		i32.shl
		local.get $idx
		i32.load8_u offset=1
		i32.or
		return
	)
	(func $load32 (param $idx i32) (result i32)
	(local $val i32)
	global.get $is_le
	if
		local.get $idx
		i32.load
		return
	end
	local.get $idx
	i32.load
	local.tee $val
    i32.const 0x000000FF
    i32.and
    i32.const 24
    i32.shl

    local.get $val
    i32.const 0x0000FF00
    i32.and
    i32.const 8
    i32.shl
    i32.or

    local.get $val
    i32.const 0x00FF0000
    i32.and
    i32.const 8
    i32.shr_u
    i32.or

    local.get $val
    i32.const 0xFF000000
    i32.and
    i32.const 24
    i32.shr_u
    i32.or
    
    return
	)
	;; (func $load32 (param $idx i32) (result i32)
	;; 	global.get $is_le
	;; 	if
	;; 		local.get $idx
	;; 		i32.load
	;; 		return
	;; 	end
	;; 	local.get $idx
	;; 	i32.load8_u
	;; 	i32.const 24
	;; 	i32.shl
	;; 	local.get $idx
	;; 	i32.load8_u offset=1
	;; 	i32.const 16
	;; 	i32.shl
	;; 	i32.or
	;; 	local.get $idx
	;; 	i32.load8_u offset=2
	;; 	i32.const 8
	;; 	i32.shl
	;; 	i32.or
	;; 	local.get $idx
	;; 	i32.load8_u offset=3
	;; 	i32.or
	;; 	return
	;; )
	(func $load64 (param $idx i32) (result i64)
		global.get $is_le
		if
			local.get $idx
			i64.load
			return
		end
		local.get $idx
		i64.load8_u
		i64.const 56
		i64.shl
		local.get $idx
		i64.load8_u offset=1
		i64.const 48
		i64.shl
		i64.or
		local.get $idx
		i64.load8_u offset=2
		i64.const 40
		i64.shl
		i64.or
		local.get $idx
		i64.load8_u offset=3
		i64.const 32
		i64.shl
		i64.or
		local.get $idx
		i64.load8_u offset=4
		i64.const 24
		i64.shl
		i64.or
		local.get $idx
		i64.load8_u offset=5
		i64.const 16
		i64.shl
		i64.or
		local.get $idx
		i64.load8_u offset=6
		i64.const 8
		i64.shl
		i64.or
		local.get $idx
		i64.load8_u offset=7
		i64.or
		return
	)
	(func $loadf32 (param $idx i32) (result f32)
		local.get $idx
		call $load32
		f32.reinterpret_i32
	)
	(func $loadf64 (param $idx i32) (result f64)
		local.get $idx
		call $load64
		f64.reinterpret_i64
	)

	(export "load16" (func $load16))
	(export "load32" (func $load32))
	(export "load64" (func $load64))
	(export "loadf32" (func $loadf32))
	(export "loadf64" (func $loadf64))


	(func $parse_tag_end (result i32)
		i32.const 0
	)
	(func $parse_tag_byte (result i32)
		global.get $index
		i32.load8_s
		call $push_byte
		call $inc
		i32.const 1
	)
	(func $parse_tag_short (result i32)
		global.get $index
		call $load16
		call $push_short
		i32.const 2
		call $incn
		i32.const 2
	)
	(func $parse_tag_int (result i32)
		global.get $index
		call $load32
		call $push_int
		i32.const 4
		call $incn
		i32.const 3
	)
	(func $parse_tag_long (result i32)
		global.get $index
		call $load64
		call $push_long
		i32.const 8
		call $incn
		i32.const 4
	)
	(func $parse_tag_float (result i32)
		global.get $index
		call $loadf32
		call $push_float
		i32.const 4
		call $incn
		i32.const 5
	)
	(func $parse_tag_double (result i32)
		global.get $index
		call $loadf64
		call $push_double
		i32.const 8
		call $incn
		i32.const 6
	)
	(func $parse_tag_byte_array (result i32)
		(local $length i32)
		global.get $index
		call $load32
		local.set $length
		global.get $index
		i32.const 4
		i32.add
		global.set $index
		global.get $index
		local.get $length
		call $push_byte_array
		local.get $length
		call $incn
		i32.const 7
	)
	(func $parse_tag_string (result i32)
		(local $length i32)
		(local $string_start i32)
		global.get $index
		call $load16
		local.set $length
		global.get $index
		i32.const 2
		i32.add
		local.tee $string_start
		local.get $length
		call $push_string
		local.get $length
		i32.const 2
		i32.add
		call $incn
		i32.const 8
	)
	(func $parse_tag_list (result i32)
		(local $type i32)
		(local $count i32)
		(local $count2 i32)
		global.get $index
		i32.load8_s
		local.set $type
		global.get $index
		i32.const 1
		i32.add
		call $load32
		local.set $count2
		local.get $count2
		local.set $count
		global.get $index
		i32.const 5
		i32.add
		global.set $index
		local.get $count
		i32.eqz
		if
			i32.const 0
			call $push_list
			i32.const 9
			return
		end
		loop $loop
			local.get $count
			i32.const 1
			i32.sub
			local.set $count
			local.get $type
			call_indirect $parse_table (result i32)
			drop
			local.get $count
			i32.const 0
			i32.ne
			br_if $loop
		end
		local.get $count2
		call $push_list
		i32.const 9
	)
	(func $parse_tag_compound (result i32)
		(local $var0 i32)
		(local $count i32)
		(i32.eqz (global.get $root))
		if (result i32 i32)
				i32.const 0
				i32.const 0
		else
				global.get $index
				call $load16
				local.set $var0
				global.get $index
				i32.const 2
				i32.add
				local.get $var0
				i32.add
				global.set $index
				i32.const 0
				global.set $root
				i32.const 0
				i32.const 0
		end
		loop $loop
			global.get $index
			i32.load8_s
			local.tee $var0
			call $inc
			i32.const 0
			i32.ne
			if
				call $parse_tag_string
				drop
				local.get $var0
				call_indirect $parse_table (result i32)
				drop
				local.get $count
				i32.const 1
				i32.add
				local.set $count
				br $loop
			else
			end
		end
		local.get $count
		call $push_compound
		i32.const 10
	)
	(func $parse_tag_int_array (result i32)
		(local $length i32)
		global.get $index
		call $load32
		local.set $length
		global.get $index
		i32.const 4
		i32.add
		global.set $index
		global.get $index
		local.get $length
		call $push_int_array
		local.get $length
		i32.const 4
		i32.mul
		call $incn
		i32.const 11
	)
	(func $parse_tag_long_array (result i32)
		(local $length i32)
		global.get $index
		call $load32
		local.set $length
		global.get $index
		i32.const 4
		i32.add
		global.set $index
		global.get $index
		local.get $length
		call $push_long_array
		local.get $length
		i32.const 8
		i32.mul
		call $incn
		i32.const 12
	)
	(func $parse (param $root i32) (param $le i32) (result i32)
		(global.set $root (local.get $root))
		(global.set $is_le (local.get $le))
		i32.const 0
		global.set $index
		i32.const 0
		i32.load8_s
		call $inc
		call_indirect $parse_table (result i32)
	)
	(func $parse_from_index (param $start_index i32) (param $root i32) (param $le i32) (result i32)
		(global.set $root (local.get $root))
		(global.set $is_le (local.get $le))
		local.get $start_index
		global.set $index
		global.get $index
		i32.load8_s
		call $inc
		call_indirect $parse_table (result i32)
	)
	(export "parse" (func $parse))
	(export "parse_from_index" (func $parse_from_index))
	(table $parse_table 13 funcref)
	(elem (i32.const 0) $parse_tag_end)
	(elem (i32.const 1) $parse_tag_byte)
	(elem (i32.const 2) $parse_tag_short)
	(elem (i32.const 3) $parse_tag_int)
	(elem (i32.const 4) $parse_tag_long)
	(elem (i32.const 5) $parse_tag_float)
	(elem (i32.const 6) $parse_tag_double)
	(elem (i32.const 7) $parse_tag_byte_array)
	(elem (i32.const 8) $parse_tag_string)
	(elem (i32.const 9) $parse_tag_list)
	(elem (i32.const 10) $parse_tag_compound)
	(elem (i32.const 11) $parse_tag_int_array)
	(elem (i32.const 12) $parse_tag_long_array)
)