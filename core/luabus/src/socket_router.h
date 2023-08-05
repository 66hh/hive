﻿#pragma once
#include <memory>
#include <array>
#include <vector>
#include <set>
#include "var_int.h"
#include "socket_mgr.h"
#include "socket_helper.h"

enum class rpc_type : uint8_t {
	remote_call,
	forward_target,
	forward_master,
	forward_broadcast,
	forward_hash,
	forward_router,
};

const int MAX_SERVICE_GROUP = (UCHAR_MAX + 1);
inline uint32_t get_group_idx(uint32_t node_id) { return  (node_id >> 16) & 0xff; }
inline uint32_t get_node_index(uint32_t node_id) { return node_id & 0xfff; }
inline uint32_t build_service_id(uint16_t group_idx, uint16_t index) { return (group_idx & 0xff) << 16 | index; }

struct service_node {
	uint32_t id		= 0;
	uint32_t token  = 0;
	uint16_t index  = 0;
	uint8_t  status = 0;
};

struct router_node {
	uint32_t id			= 0;//路由服id
	std::set<uint32_t> targets;//目标节点
	std::set<uint16_t> groups; //目标组
	inline void flush_group() {
		groups.clear();
		for (auto it : targets) {
			groups.insert(get_group_idx(it));
		}
	}
};

constexpr int ROUTER_HEAD_LEN = MAX_VARINT_SIZE * 4;

struct router_header {
	uint64_t rpc_flag   = 0;
	uint64_t source_id  = 0;
	uint64_t session_id = 0;
};

struct service_group {
	uint16_t hash = 0;
	service_node master;
	std::vector<uint32_t> hash_ids;
	std::unordered_map<uint32_t, service_node> mp_nodes;
	inline service_node* get_target(uint32_t id) {
		auto it = mp_nodes.find(id);
		if (it != mp_nodes.end()) {
			return &it->second;
		}
		return nullptr;
	}
	inline service_node* hash_target(uint64_t hash) {
		auto count = hash_ids.size();
		if (count > 0) {
			auto id = hash_ids[hash % count];
			auto it = mp_nodes.find(id);
			if (it != mp_nodes.end()) {
				return &it->second;
			}
		}
		return nullptr;
	}
};

class socket_router
{
public:
	socket_router(std::shared_ptr<socket_mgr>& mgr) : m_mgr(mgr) { }

	uint32_t map_token(uint32_t node_id, uint32_t token, uint16_t hash);
	uint32_t set_node_status(uint32_t node_id, uint8_t status);
	void set_service_name(uint32_t service_id, std::string service_name);
	void map_router_node(uint32_t router_id, uint32_t target_id, uint8_t status);	
	void set_router_id(uint32_t node_id);
	uint32_t choose_master(uint32_t group_idx);
	void flush_hash_node(uint32_t group_idx);

	bool do_forward_target(router_header* header, char* data, size_t data_len, std::string& error, bool router);
	bool do_forward_master(router_header* header, char* data, size_t data_len, std::string& error, bool router);
	bool do_forward_broadcast(router_header* header, int source, char* data, size_t data_len, size_t& broadcast_num);
	bool do_forward_hash(router_header* header, char* data, size_t data_len, std::string& error, bool router);
	size_t format_header(BYTE* header_data, size_t data_len, router_header* header, rpc_type msgid);

	bool do_forward_router(router_header* header, char* data, size_t data_len, std::string& error, rpc_type msgid,uint64_t target_id, uint16_t group_idx);

protected:
	uint32_t find_transfer_router(uint32_t target_id, uint16_t group_idx);
	uint16_t cur_index() { return get_node_index(m_node_id); };
	std::string get_service_name(uint32_t service_id);
	std::string get_service_nick(uint32_t target_id);

private:
	std::shared_ptr<socket_mgr> m_mgr;
	std::unordered_map<uint32_t, std::string> m_service_names;
	std::array<service_group, MAX_SERVICE_GROUP> m_groups;
	std::unordered_map<uint32_t, router_node> m_routers;
	std::unordered_map<uint32_t, router_node>::iterator m_router_iter = m_routers.begin();
	int16_t m_router_idx = -1;
	uint32_t m_node_id = 0;
	BYTE m_header_data[ROUTER_HEAD_LEN];
};

