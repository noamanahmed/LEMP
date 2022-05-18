<?xml version="1.0" encoding="UTF-8"?>
<FileZilla3 version="3.58.0" platform="*nix">
	<Servers>
		<Server>
			<Host>{{$domain}}</Host>
			<Port>{{$port}}</Port>
			<Protocol>1</Protocol>
			<Type>0</Type>
			<User>{{$username}}</User>
			<Pass encoding="base64">{{$password}}</Pass>
			<Logontype>1</Logontype>
			<EncodingType>Auto</EncodingType>
			<BypassProxy>0</BypassProxy>
			<Name>site_{{$username}}</Name>
			<SyncBrowsing>0</SyncBrowsing>
			<DirectoryComparison>0</DirectoryComparison>
		</Server>
	</Servers>
</FileZilla3>