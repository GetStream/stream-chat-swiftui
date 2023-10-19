MAKEFLAGS += --silent

update_dependencies:
	echo "👉 Updating Nuke"
	make update_nuke version=11.3.1
	echo "👉 Updating SwiftyGif"
	make update_swiftygif version=5.4.2

update_nuke: check_version_parameter
	./Scripts/updateDependency.sh $(version) Dependencies/Nuke Sources/StreamChatSwiftUI/StreamNuke Sources
	./Scripts/removePublicDeclarations.sh Sources/StreamChatSwiftUI/StreamNuke

update_swiftygif: check_version_parameter
	./Scripts/updateDependency.sh $(version) Dependencies/SwiftyGif Sources/StreamChatSwiftUI/StreamSwiftyGif SwiftyGif
	./Scripts/removePublicDeclarations.sh Sources/StreamChatSwiftUI/StreamSwiftyGif

check_version_parameter:
	@if [ "$(version)" = "" ]; then\
		echo "❌ Missing version parameter"; \
        exit 1;\
    fi
