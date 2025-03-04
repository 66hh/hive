
#include "lcodec.h"

namespace lcodec {

    thread_local rdscodec thread_rds;
    thread_local httpcodec thread_http;
    thread_local luakit::luabuf thread_buff;

    static rdscodec* rds_codec(codec_base* codec) {
        thread_rds.set_codec(codec);
        thread_rds.set_buff(&thread_buff);
        return &thread_rds;
    }

    static httpcodec* http_codec(codec_base* codec) {
        thread_http.set_codec(codec);
        thread_http.set_buff(&thread_buff);
        return &thread_http;
    }

    static int serialize(lua_State* L) {
        return luakit::serialize(L, &thread_buff);
    }
    static int unserialize(lua_State* L) {
        return luakit::unserialize(L);
    }
    static int encode(lua_State* L) {
        return luakit::encode(L, &thread_buff);
    }
    static int decode(lua_State* L) {
        return luakit::decode(L, &thread_buff);
    }
    static std::string utf8_gbk(std::string str) {
        char pOut[1024];
        memset(pOut, 0, sizeof(pOut));
        utf8_to_gb(str.c_str(), pOut, sizeof(pOut));        
        return pOut;
    }
    static std::string gbk_utf8(std::string str) {
        char pOut[1024];
        memset(pOut, 0, sizeof(pOut));
        gb_to_utf8(str.c_str(), pOut, sizeof(pOut));
        return pOut;
    }

    static bitarray* barray(lua_State* L, size_t nbits) {
        bitarray* barray = new bitarray();
        if (!barray->general(nbits)) {
            delete barray;
            return nullptr;
        }
        return barray;
    }

    static int lcrc8(lua_State* L) {
        size_t len;
        const char* key = lua_tolstring(L, 1, &len);
        lua_pushinteger(L, crc8_lsb(key, len));
        return 1;
    }

    static int lcrc8_msb(lua_State* L) {
        size_t len;
        const char* key = lua_tolstring(L, 1, &len);
        lua_pushinteger(L, crc8_msb(key, len));
        return 1;
    }

    static int lcrc16(lua_State* L) {
        size_t len;
        const char* key = lua_tolstring(L, 1, &len);
        lua_pushinteger(L, crc16(key, len));
        return 1;
    }

    static int lcrc32(lua_State* L) {
        size_t len;
        const char* key = lua_tolstring(L, 1, &len);
        lua_pushinteger(L, crc32(key, len));
        return 1;
    }

    static int lcrc64(lua_State* L) {
        size_t len;
        const char* key = lua_tolstring(L, 1, &len);
        lua_pushinteger(L, (int64_t)crc64(key, len));
        return 1;
    }

    luakit::lua_table open_lcodec(lua_State* L) {
        luakit::kit_state kit_state(L);
        auto llcodec = kit_state.new_table();
        llcodec.set_function("encode", encode);
        llcodec.set_function("decode", decode);
        llcodec.set_function("serialize", serialize);
        llcodec.set_function("unserialize", unserialize);
        llcodec.set_function("guid_new", guid_new);
        llcodec.set_function("guid_encode", guid_encode);
        llcodec.set_function("guid_decode", guid_decode);
        llcodec.set_function("guid_group", guid_group);
        llcodec.set_function("guid_index", guid_index);
        llcodec.set_function("guid_type", guid_type); 
        llcodec.set_function("guid_serial", guid_serial);
        llcodec.set_function("guid_time", guid_time);
        llcodec.set_function("guid_source", guid_source);
        llcodec.set_function("hash_code", hash_code);
        llcodec.set_function("jumphash", jumphash_l);
        llcodec.set_function("fnv_1_32", fnv_1_32_l);
        llcodec.set_function("fnv_1a_32", fnv_1a_32_l);
        llcodec.set_function("murmur3_32", murmur3_32_l);
        llcodec.set_function("bitarray", barray);
        llcodec.set_function("rediscodec", rds_codec);
        llcodec.set_function("httpcodec", http_codec);

        llcodec.set_function("utf8_gbk", utf8_gbk);
        llcodec.set_function("gbk_utf8", gbk_utf8);

        llcodec.set_function("crc8_msb", lcrc8_msb);
        llcodec.set_function("crc64", lcrc64);
        llcodec.set_function("crc32", lcrc32);
        llcodec.set_function("crc16", lcrc16);
        llcodec.set_function("crc8", lcrc8);

        kit_state.new_class<bitarray>(
            "flip", &bitarray::flip,
            "fill", &bitarray::fill,
            "equal", &bitarray::equal,
            "clone", &bitarray::clone,
            "slice", &bitarray::slice,
            "concat", &bitarray::concat,
            "lshift", &bitarray::lshift,
            "rshift", &bitarray::rshift,
            "length", &bitarray::length,
            "resize", &bitarray::resize,
            "reverse", &bitarray::reverse,
            "set_bit", &bitarray::set_bit,
            "get_bit", &bitarray::get_bit,
            "flip_bit", &bitarray::flip_bit,
            "to_string", &bitarray::to_string,
            "from_string", &bitarray::from_string,
            "to_uint8", &bitarray::to_number<uint8_t>,
            "to_uint16", &bitarray::to_number<uint16_t>,
            "to_uint32", &bitarray::to_number<uint32_t>,
            "to_uint64", &bitarray::to_number<uint64_t>,
            "from_uint8", &bitarray::from_number<uint8_t>,
            "from_uint16", &bitarray::from_number<uint16_t>,
            "from_uint32", &bitarray::from_number<uint32_t>,
            "from_uint64", &bitarray::from_number<uint64_t>
            );

        return llcodec;
    }
}

extern "C" {
    LUALIB_API int luaopen_lcodec(lua_State* L) {
        auto lcodec = lcodec::open_lcodec(L);
        return lcodec.push_stack();
    }
}
