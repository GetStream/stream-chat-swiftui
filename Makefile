MAKEFLAGS += --silent

update_dependencies:
	echo "👉 Updating SwiftyGif"
	make update_swiftygif version=5.4.2

update_swiftygif: check_version_parameter
	./Scripts/updateDependency.sh $(version) Dependencies/SwiftyGif Sources/StreamChatSwiftUI/StreamSwiftyGif SwiftyGif
	./Scripts/removePublicDeclarations.sh Sources/StreamChatSwiftUI/StreamSwiftyGif

check_version_parameter:
	@if [ "$(version)" = "" ]; then\
		echo "❌ Missing version parameter"; \
        exit 1;\
    fi
