MAKEFLAGS += --silent

update_dependencies:
	echo "👉 Updating SwiftyGif"
	make update_swiftygif version=5.4.2

update_swiftygif: check_version_parameter
	./Scripts/updateDependency.sh $(version) Dependencies/SwiftyGif Sources/StreamChatSwiftUI/StreamSwiftyGif SwiftyGif
	./Scripts/removePublicDeclarations.sh Sources/StreamChatSwiftUI/StreamSwiftyGif
	# Local changes (Swift 6 concurrency, multi-display visibility check) live in a patch
	# so they survive updates. Regenerate the patch if it no longer applies to a new version.
	git apply --whitespace=nowarn Scripts/Patches/SwiftyGif.patch

check_version_parameter:
	@if [ "$(version)" = "" ]; then\
		echo "❌ Missing version parameter"; \
        exit 1;\
    fi
