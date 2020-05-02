function list(target, domain_id)
end

local rrset
local rrsetsize
local rrsetidx

function lookup(qtype, qname, domain_id)
	rrset = {}
	rrsetidx = 0
	rrsetsize = 0

	authzone = extract_authzone(qname)
	if authzone ~= nil then

		net = string.sub(authzone, 3, 3) .. string.sub(authzone, 1, 1)
		table.insert(rrset, {name = authzone, type = "NS", content = "2a0b-f4c0-" .. net .. "-8053--53.deleg.f3netze.de.", auth = 0})
		table.insert(rrset, {name = authzone, type = "NS", content = "2a0b-f4c0-" .. net .. "-8153--53.deleg.f3netze.de.", auth = 0})
		--table.insert(rrset, {content = "2a0b:f4c0" .. "::1", type = "AAAA", name = "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0." .. authzone, auth = 0})
		--table.insert(rrset, {content = "2a0b:f4c0" .. "::2", type = "AAAA", name = "2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0." .. authzone, auth = 0})
		
	end

	-- FIXME: compare qtype
	--if qtype.getName() == "AAAA" then
		forwardrecord = extract_forwardrecord(qname)
		if forwardrecord ~= nil then
			table.insert(rrset, {name = qname, type = "AAAA", content = forwardrecord, auth = 1})
		end
	--end

	-- 2a0b:f4c0::/40
	-- 2a0b:f4c0:0073::/48
	-- 2a0b:f4c0:0073:xxxx::/64
	--
	-- 2a0b:f4c0:0073:8053::/64
	-- 2a0b-f4c0-73-8053--53
	-- 2a0b:f4c0:0073:8153::/64
	-- 2a0b-f4c0-73-8153--53
	-- 2a0b-f4c0-73-8153-0-0-0-53
	--
	-- createReverse('%33%')  ?

	rrsetsize = #rrset
end

function get()
	while rrsetidx < rrsetsize do
		rrsetidx = rrsetidx + 1
		return rrset[rrsetidx]
	end
	return false
end

function getsoa(name)
	if name ~= "0.0.0.c.4.f.b.0.a.2.ip6.arpa." then
		if name ~= "deleg.f3netze.de." then
			return false
		end
	end

	soa = {
		nameserver = "me.",
		hostmaster = "me.",
		serial = 2005092501,
		refresh = 7200,
		retry = 3600,
		expire = 1209600,
		default_ttl = 3600,
		ttl = 3600
	}
	return soa
end

function extract_authzone(name)
	-- Form validation
	--

	if string.find(name, ".0.0.0.c.4.f.b.0.a.2.ip6.arpa.", -30) == nil then
		return nil
	end

	auth = string.sub(name, -33, -31)
	if string.len(auth) ~= 3 then
		return nil
	end

	if string.sub(auth, 2, 2) ~= "." then
		return nil
	end

	authzone = auth .. ".0.0.0.c.4.f.b.0.a.2.ip6.arpa."
	return authzone
end

function extract_forwardrecord(name)
	-- Form validation
	--
	if string.find(name, "2a0b-f4c0-", 0) == nil then
		-- FIXME: comparison returns nil?
		--return nil
	end
	if string.find(name, ".deleg.f3netze.de.", -18) == nil then
		return nil
	end

	record = string.sub(name, 0, -19)
	record = string.gsub(record, "-", ":")
	return record
end
