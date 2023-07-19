.PHONY: all clean extra repo aur-repo rebuild uninstall
# MODE := "source"
ARCH := $(shell uname -m)
WORKSPACE_DIR := $(shell pwd)
REPO_ROOT := $(WORKSPACE_DIR)/.repo
REPO_DIR := $(REPO_ROOT)/$(ARCH)
PACMAN_CONF := $(REPO_ROOT)/pacman-$(ARCH).conf

ifeq ($(MODE), repo)
	RUN_MAKEPKG := "$(WORKSPACE_DIR)/tools/pkg-build/repo-build.sh" "$(REPO_DIR)" "$(REPO_ROOT)/pacman-wrapper-$(ARCH).sh"
else 
	RUN_MAKEPKG := "$(WORKSPACE_DIR)/tools/pkg-build/source-build.sh"
endif

OVOS_PACKAGES := $(notdir $(wildcard PKGBUILDs/*))
EXTRA_PACKAGES := $(notdir $(wildcard PKGBUILDs-extra/*))
ALL_PACKAGES := $(OVOS_PACKAGES) + $(EXTRA_PACKAGES)

# The default target will build all OVOS packages and only those 'extra' dependent packages which are in use
all: $(OVOS_PACKAGES)

extra: $(EXTRA_PACKAGES)

clean: rebuild
	@rm -rf ./{PKGBUILDs,PKGBUILDs-extra}/*/{pkg,src}
rebuild:
	@echo 'Deleted any built packages, you may now run make all'
	@rm -rf ./{PKGBUILDs,PKGBUILDs-extra}/*/*.pkg.tar* $(REPO_DIR)

uninstall:
	@pacman -Qq | sort | comm -12 - <(echo "$(ALL_PACKAGES)" | tr ' ' '\n' | sort) | xargs sudo pacman -Rcns --noconfirm

repo: aur-repo
	@mkdir -p "$(REPO_DIR)/"
	@cp /etc/pacman.conf "$(PACMAN_CONF)"
	@printf "\n\n[ovos-arch]\nSigLevel = Optional TrustAll\nServer = file:///$(REPO_DIR)" >> $(PACMAN_CONF)
	@cp "$(WORKSPACE_DIR)/tools/pkg-build/pacman-wrapper.sh" "$(REPO_ROOT)/pacman-wrapper-$(ARCH).sh"
	@sed -i 's|/etc/pacman.conf|$(PACMAN_CONF)|g' "$(REPO_ROOT)/pacman-wrapper-$(ARCH).sh"
	@chmod +x "$(REPO_ROOT)/pacman-wrapper-$(ARCH).sh"
ifeq (, $(wildcard $(REPO_DIR)/ovos-arch.db.tar.gz))
	@repo-add "$(REPO_DIR)/ovos-arch.db.tar.gz"
	@echo "Repo created..."
endif

sync-repo:
	@"$(REPO_ROOT)/pacman-wrapper-$(ARCH).sh" -Syy 

aur-repo:
	@mkdir -p "$(WORKSPACE_DIR)/AUR"
	./tools/aur-repo.sh "$(WORKSPACE_DIR)/AUR/" "$(WORKSPACE_DIR)/aur.lock"

%.pkg.tar.zst:
	$(eval DIR := $(shell echo '$*' | cut -d* -f1))
	@echo "Building $(DIR) with ''$(RUN_MAKEPKG)''"
	@cd $(DIR) && $(RUN_MAKEPKG)
	
mycroft-gui-qt5:  PKGBUILDs/mycroft-gui-qt5/*.pkg.tar.zst

mycroft-mimic1:  PKGBUILDs/mycroft-mimic1/*.pkg.tar.zst

mycroft-mimic1-voices:  PKGBUILDs/mycroft-mimic1/*.pkg.tar.zst

mycroft-mimic3-tts-bin:  PKGBUILDs/mycroft-mimic3-tts-bin/*.pkg.tar.zst

nsync:  PKGBUILDs-extra/nsync/*.pkg.tar.zst

onnxruntime:  PKGBUILDs-extra/onnxruntime-bin/*.pkg.tar.zst

ovos-bus-server: ovos-service-base PKGBUILDs/ovos-bus-server/*.pkg.tar.zst

ovos-core: python-ovos-core python-ovos-messagebus PKGBUILDs/ovos-core/*.pkg.tar.zst

ovos-dashboard:  PKGBUILDs/ovos-dashboard/*.pkg.tar.zst

ovos-enclosure-audio-pulse:  PKGBUILDs/ovos-enclosure-audio-pulse/*.pkg.tar.zst

ovos-enclosure-audio-vocalfusion-dkms:  PKGBUILDs/ovos-enclosure-audio-vocalfusion-dkms/*.pkg.tar.zst

ovos-enclosure-base: ovos-core ovos-shell-standalone python-ovos-messagebus python-ovos-dinkum-listener python-ovos-gui python-ovos-phal python-ovos-phal python-ovos-audio python-ovos-core python-ovos-tts-plugin-mimic python-ovos-tts-plugin-mimic3-server ovos-skill-official-homescreen ovos-skill-official-naptime ovos-skill-official-date-time ovos-skill-official-volume ovos-skill-official-fallback-unknown PKGBUILDs/ovos-enclosure-base/*.pkg.tar.zst

ovos-enclosure-rpi4-mark2: ovos-enclosure-base ovos-enclosure-sj201 PKGBUILDs/ovos-enclosure-rpi4-mark2/*.pkg.tar.zst

ovos-enclosure-sj201: ovos-enclosure-audio-vocalfusion-dkms python-spidev python-rpi.gpio python-smbus2 PKGBUILDs/ovos-enclosure-sj201/*.pkg.tar.zst

ovos-precise-lite-models:  PKGBUILDs/ovos-precise-lite-models/*.pkg.tar.zst

ovos-service-base:  PKGBUILDs/ovos-service-base/*.pkg.tar.zst

ovos-shell: mycroft-gui-qt5 python-ovos-phal-plugin-alsa python-ovos-phal-plugin-system python-ovos-phal-plugin-configuration-provider PKGBUILDs/ovos-shell/*.pkg.tar.zst

ovos-shell-standalone: ovos-service-base ovos-shell PKGBUILDs/ovos-shell-standalone/*.pkg.tar.zst

ovos-skill-neon-local-music: python-ovos-workshop python-ovos-ocp-audio-plugin python-ovos-ocp-files-plugin python-ovos-utils python-ovos-skill-installer PKGBUILDs/ovos-skill-neon-local-music/*.pkg.tar.zst

ovos-skill-official-camera: python-ovos-utils python-ovos-workshop PKGBUILDs/ovos-skill-official-camera/*.pkg.tar.zst

ovos-skill-official-date-time: python-ovos-workshop python-ovos-utils python-timezonefinder python-tzlocal PKGBUILDs/ovos-skill-official-date-time/*.pkg.tar.zst

ovos-skill-official-fallback-unknown: python-ovos-utils python-ovos-workshop PKGBUILDs/ovos-skill-official-fallback-unknown/*.pkg.tar.zst

ovos-skill-official-homescreen: python-ovos-utils python-ovos-workshop python-ovos-lingua-franca python-ovos-phal-plugin-wallpaper-manager python-ovos-skill-manager PKGBUILDs/ovos-skill-official-homescreen/*.pkg.tar.zst

ovos-skill-official-naptime: python-ovos-workshop python-ovos-bus-client python-ovos-utils PKGBUILDs/ovos-skill-official-naptime/*.pkg.tar.zst

ovos-skill-official-news: python-ovos-ocp-audio-plugin python-ovos-workshop PKGBUILDs/ovos-skill-official-news/*.pkg.tar.zst

ovos-skill-official-setup: python-ovos-backend-client python-ovos-utils python-ovos-workshop python-ovos-phal-plugin-system python-ovos-plugin-manager PKGBUILDs/ovos-skill-official-setup/*.pkg.tar.zst

ovos-skill-official-stop: python-ovos-workshop python-ovos-utils PKGBUILDs/ovos-skill-official-stop/*.pkg.tar.zst

ovos-skill-official-volume: python-ovos-utils PKGBUILDs/ovos-skill-official-volume/*.pkg.tar.zst

ovos-skill-official-weather: python-ovos-workshop python-ovos-utils PKGBUILDs/ovos-skill-official-weather/*.pkg.tar.zst

ovos-skill-official-youtube-music: python-ovos-ocp-youtube-plugin python-ovos-utils python-ovos-workshop python-tutubo PKGBUILDs/ovos-skill-official-youtube-music/*.pkg.tar.zst

ovos-splash:  PKGBUILDs/ovos-splash/*.pkg.tar.zst

python-adapt-parser:  PKGBUILDs-extra/python-adapt-parser/*.pkg.tar.zst

python-bitstruct:  PKGBUILDs-extra/python-bitstruct/*.pkg.tar.zst

python-bs4:  PKGBUILDs-extra/python-bs4/*.pkg.tar.zst

python-cattrs:  PKGBUILDs-extra/python-cattrs/*.pkg.tar.zst

python-combo-lock: python-filelock python-memory-tempfile PKGBUILDs-extra/python-combo-lock/*.pkg.tar.zst

python-convertdate: aur-repo AUR/python-convertdate/*.pkg.tar.zst

python-crfsuite-git:  PKGBUILDs-extra/python-crfsuite-git/*.pkg.tar.zst

python-cutecharts:  PKGBUILDs-extra/python-cutecharts/*.pkg.tar.zst

python-dataclasses-json: aur-repo python-marshmallow-enum AUR/python-dataclasses-json/*.pkg.tar.zst

python-dateparser: aur-repo python-tzlocal python-convertdate python-hijri-converter AUR/python-dateparser/*.pkg.tar.zst

python-deezeridu:  PKGBUILDs-extra/python-deezeridu/*.pkg.tar.zst

python-epitran: aur-repo python-marisa-trie python-panphon AUR/python-epitran/*.pkg.tar.zst

python-espeak-phonemizer:  PKGBUILDs-extra/python-espeak-phonemizer/*.pkg.tar.zst

python-filelock:  PKGBUILDs-extra/python-filelock/*.pkg.tar.zst

python-gradio: python-uvicorn PKGBUILDs-extra/python-gradio/*.pkg.tar.zst

python-gruut: python-dateparser python-gruut-ipa python-gruut-lang-en python-num2words python-crfsuite-git PKGBUILDs-extra/python-gruut/*.pkg.tar.zst

python-gruut-ipa: aur-repo AUR/python-gruut-ipa/*.pkg.tar.zst

python-gruut-lang-en: aur-repo AUR/python-gruut-lang-en/*.pkg.tar.zst

python-h3:  PKGBUILDs-extra/python-h3/*.pkg.tar.zst

python-hijri-converter: aur-repo AUR/python-hijri-converter/*.pkg.tar.zst

python-json-database: python-combo-lock PKGBUILDs-extra/python-json-database/*.pkg.tar.zst

python-kthread:  PKGBUILDs-extra/python-kthread/*.pkg.tar.zst

python-langcodes:  PKGBUILDs-extra/python-langcodes/*.pkg.tar.zst

python-marisa-trie: aur-repo AUR/python-marisa-trie/*.pkg.tar.zst

python-marshmallow-enum: aur-repo AUR/python-marshmallow-enum/*.pkg.tar.zst

python-memory-tempfile:  PKGBUILDs-extra/python-memory-tempfile/*.pkg.tar.zst

python-mycroft-messagebus-client:  PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst

python-mycroft-mimic3-tts: python-espeak-phonemizer python-dataclasses-json python-epitran python-gruut python-onnxruntime python-phonemes2ids python-xdgenvpy PKGBUILDs/python-mycroft-mimic3-tts/*.pkg.tar.zst

python-nested-lookup:  PKGBUILDs-extra/python-nested-lookup/*.pkg.tar.zst

python-num2words: aur-repo AUR/python-num2words/*.pkg.tar.zst

python-onnxruntime: onnxruntime nsync PKGBUILDs-extra/onnxruntime/*.pkg.tar.zst

python-ovos-audio: ovos-core ovos-service-base python-ovos-messagebus python-sdnotify python-ovos-ocp-audio-plugin python-ovos-bus-client python-ovos-config python-ovos-ocp-files-plugin python-ovos-ocp-m3u-plugin python-ovos-ocp-news-plugin python-ovos-ocp-rss-plugin python-ovos-plugin-manager python-ovos-utils PKGBUILDs/python-ovos-audio/*.pkg.tar.zst

python-ovos-audio-plugin-simple: python-ovos-plugin-manager PKGBUILDs/python-ovos-audio-plugin-simple/*.pkg.tar.zst

python-ovos-backend-client: python-json-database python-ovos-utils PKGBUILDs/python-ovos-backend-client/*.pkg.tar.zst

python-ovos-backend-manager: python-cutecharts python-ovos-personal-backend python-pywebio PKGBUILDs/python-ovos-backend-manager/*.pkg.tar.zst

python-ovos-bus-client: python-ovos-config python-ovos-utils PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst

python-ovos-classifiers: python-ovos-utils PKGBUILDs/python-ovos-classifiers/*.pkg.tar.zst

python-ovos-cli-client: python-ovos-utils python-ovos-bus-client PKGBUILDs/python-ovos-cli-client/*.pkg.tar.zst

python-ovos-config: python-combo-lock python-ovos-utils python-rich-click PKGBUILDs/python-ovos-config/*.pkg.tar.zst

python-ovos-config-assistant: python-cutecharts python-ovos-backend-client python-ovos-utils python-pywebio PKGBUILDs/python-ovos-config-assistant/*.pkg.tar.zst

python-ovos-core: ovos-service-base python-ovos-messagebus python-sdnotify python-adapt-parser python-combo-lock python-ovos-backend-client python-ovos-bus-client python-ovos-workshop python-ovos-classifiers python-ovos-config python-ovos-lingua-franca python-ovos-plugin-manager python-ovos-utils python-padacioso PKGBUILDs/python-ovos-core/*.pkg.tar.zst

python-ovos-dinkum-listener: ovos-core ovos-service-base python-ovos-messagebus python-sdnotify python-ovos-microphone-plugin-alsa python-ovos-backend-client python-ovos-bus-client python-ovos-config python-ovos-plugin-manager python-ovos-utils python-speechrecognition PKGBUILDs/python-ovos-dinkum-listener/*.pkg.tar.zst

python-ovos-gui: ovos-core ovos-service-base python-ovos-messagebus python-sdnotify python-ovos-backend-client python-ovos-bus-client python-ovos-config python-ovos-utils PKGBUILDs/python-ovos-gui/*.pkg.tar.zst

python-ovos-lingua-franca: python-quebra-frases PKGBUILDs/python-ovos-lingua-franca/*.pkg.tar.zst

python-ovos-listener: ovos-core ovos-service-base python-ovos-messagebus python-sdnotify python-ovos-backend-client python-ovos-bus-client python-ovos-config python-ovos-plugin-manager python-ovos-stt-plugin-server python-ovos-stt-plugin-vosk python-ovos-utils python-ovos-vad-plugin-webrtcvad python-ovos-ww-plugin-pocketsphinx python-ovos-ww-plugin-precise-lite python-ovos-ww-plugin-vosk python-speechrecognition PKGBUILDs/python-ovos-listener/*.pkg.tar.zst

python-ovos-messagebus: ovos-service-base python-sdnotify python-ovos-config python-ovos-utils PKGBUILDs/python-ovos-messagebus/*.pkg.tar.zst

python-ovos-microphone-plugin-alsa: python-ovos-plugin-manager python-pyalsaaudio PKGBUILDs/python-ovos-microphone-plugin-alsa/*.pkg.tar.zst

python-ovos-microphone-plugin-pyaudio: python-ovos-plugin-manager python-speechrecognition PKGBUILDs/python-ovos-microphone-plugin-pyaudio/*.pkg.tar.zst

python-ovos-microphone-plugin-sounddevice: python-ovos-plugin-manager python-speechrecognition PKGBUILDs/python-ovos-microphone-plugin-sounddevice/*.pkg.tar.zst

python-ovos-notifications-service: python-mycroft-messagebus-client python-ovos-utils PKGBUILDs/python-ovos-notifications-service/*.pkg.tar.zst

python-ovos-ocp-audio-plugin: python-ovos-audio-plugin-simple python-ovos-workshop python-ovos-bus-client python-ovos-ocp-files-plugin python-ovos-plugin-manager python-ovos-utils python-padacioso PKGBUILDs/python-ovos-ocp-audio-plugin/*.pkg.tar.zst

python-ovos-ocp-bandcamp-plugin: python-ovos-ocp-audio-plugin python-py-bandcamp PKGBUILDs/python-ovos-ocp-bandcamp-plugin/*.pkg.tar.zst

python-ovos-ocp-deezer-plugin: python-deezeridu python-ovos-ocp-audio-plugin PKGBUILDs/python-ovos-ocp-deezer-plugin/*.pkg.tar.zst

python-ovos-ocp-files-plugin: python-bitstruct python-pprintpp PKGBUILDs/python-ovos-ocp-files-plugin/*.pkg.tar.zst

python-ovos-ocp-m3u-plugin: python-ovos-ocp-audio-plugin PKGBUILDs/python-ovos-ocp-m3u-plugin/*.pkg.tar.zst

python-ovos-ocp-news-plugin: python-ovos-ocp-audio-plugin python-ovos-ocp-m3u-plugin python-ovos-ocp-rss-plugin PKGBUILDs/python-ovos-ocp-news-plugin/*.pkg.tar.zst

python-ovos-ocp-rss-plugin: python-ovos-ocp-audio-plugin PKGBUILDs/python-ovos-ocp-rss-plugin/*.pkg.tar.zst

python-ovos-ocp-youtube-plugin: python-ovos-ocp-audio-plugin python-tutubo python-yt-dlp PKGBUILDs/python-ovos-ocp-youtube-plugin/*.pkg.tar.zst

python-ovos-personal-backend: python-json-database python-ovos-plugin-manager python-ovos-stt-plugin-server python-ovos-utils python-requests-cache python-sqlalchemy-json python-timezonefinder PKGBUILDs/python-ovos-personal-backend/*.pkg.tar.zst

python-ovos-phal: ovos-core ovos-service-base python-ovos-messagebus python-sdnotify python-ovos-workshop python-ovos-bus-client python-ovos-config python-ovos-phal-plugin-connectivity-events python-ovos-phal-plugin-ipgeo python-ovos-phal-plugin-network-manager python-ovos-phal-plugin-oauth python-ovos-phal-plugin-system python-ovos-plugin-manager python-ovos-utils PKGBUILDs/python-ovos-phal/*.pkg.tar.zst

python-ovos-phal-plugin-alsa: python-json-database python-ovos-plugin-manager python-pyalsaaudio PKGBUILDs/python-ovos-phal-plugin-alsa/*.pkg.tar.zst

python-ovos-phal-plugin-balena-wifi: python-mycroft-messagebus-client python-ovos-utils python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-balena-wifi/*.pkg.tar.zst

python-ovos-phal-plugin-brightness-control-rpi: python-mycroft-messagebus-client python-ovos-utils python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-brightness-control-rpi/*.pkg.tar.zst

python-ovos-phal-plugin-color-scheme-manager: python-mycroft-messagebus-client python-ovos-utils python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-color-scheme-manager/*.pkg.tar.zst

python-ovos-phal-plugin-configuration-provider: python-mycroft-messagebus-client python-ovos-utils python-ovos-config python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-configuration-provider/*.pkg.tar.zst

python-ovos-phal-plugin-connectivity-events: python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-connectivity-events/*.pkg.tar.zst

python-ovos-phal-plugin-dashboard: python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-dashboard/*.pkg.tar.zst

python-ovos-phal-plugin-display-manager-ipc:  PKGBUILDs/python-ovos-phal-plugin-display-manager-ipc/*.pkg.tar.zst

python-ovos-phal-plugin-gpsd:  PKGBUILDs/python-ovos-phal-plugin-gpsd/*.pkg.tar.zst

python-ovos-phal-plugin-gui-network-client: python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-gui-network-client/*.pkg.tar.zst

python-ovos-phal-plugin-homeassistant: python-mycroft-messagebus-client python-nested-lookup python-ovos-config python-ovos-phal-plugin-oauth python-ovos-plugin-manager python-ovos-utils python-pytube python-youtube-search PKGBUILDs/python-ovos-phal-plugin-homeassistant/*.pkg.tar.zst

python-ovos-phal-plugin-ipgeo: python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-ipgeo/*.pkg.tar.zst

python-ovos-phal-plugin-mk1:  PKGBUILDs/python-ovos-phal-plugin-mk1/*.pkg.tar.zst

python-ovos-phal-plugin-mk2: python-ovos-plugin-manager python-rpi.gpio python-smbus2 PKGBUILDs/python-ovos-phal-plugin-mk2/*.pkg.tar.zst

python-ovos-phal-plugin-network-manager: python-mycroft-messagebus-client python-ovos-utils python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-network-manager/*.pkg.tar.zst

python-ovos-phal-plugin-notification-widgets: python-mycroft-messagebus-client python-ovos-utils python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-notification-widgets/*.pkg.tar.zst

python-ovos-phal-plugin-oauth: python-ovos-backend-client python-ovos-utils PKGBUILDs/python-ovos-phal-plugin-oauth/*.pkg.tar.zst

python-ovos-phal-plugin-respeaker-2mic:  PKGBUILDs/python-ovos-phal-plugin-respeaker-2mic/*.pkg.tar.zst

python-ovos-phal-plugin-respeaker-4mic:  PKGBUILDs/python-ovos-phal-plugin-respeaker-4mic/*.pkg.tar.zst

python-ovos-phal-plugin-system: python-ovos-config python-ovos-plugin-manager python-ovos-utils PKGBUILDs/python-ovos-phal-plugin-system/*.pkg.tar.zst

python-ovos-phal-plugin-wallpaper-manager: python-mycroft-messagebus-client python-ovos-plugin-manager python-ovos-utils python-wallpaper-finder PKGBUILDs/python-ovos-phal-plugin-wallpaper-manager/*.pkg.tar.zst

python-ovos-phal-plugin-wifi-setup: python-mycroft-messagebus-client python-ovos-utils python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-wifi-setup/*.pkg.tar.zst

python-ovos-plugin-manager: python-combo-lock python-langcodes python-ovos-bus-client python-ovos-config python-ovos-utils python-quebra-frases PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst

python-ovos-skill-installer:  PKGBUILDs/python-ovos-skill-installer/*.pkg.tar.zst

python-ovos-skill-manager: python-bs4 python-combo-lock python-json-database python-ovos-config python-ovos-skill-installer python-ovos-utils python-pako python-requests-cache PKGBUILDs/python-ovos-skill-manager/*.pkg.tar.zst

python-ovos-skills-manager: python-bs4 python-combo-lock python-json-database python-ovos-config python-ovos-skill-installer python-ovos-utils python-pako python-requests-cache PKGBUILDs/python-ovos-skills-manager/*.pkg.tar.zst

python-ovos-stt-http-server: python-ovos-plugin-manager python-ovos-utils python-uvicorn PKGBUILDs/python-ovos-stt-http-server/*.pkg.tar.zst

python-ovos-stt-plugin-chromium: python-ovos-utils python-ovos-plugin-manager PKGBUILDs/python-ovos-stt-plugin-chromium/*.pkg.tar.zst

python-ovos-stt-plugin-pocketsphinx: python-ovos-plugin-manager python-pocketsphinx python-speechrecognition PKGBUILDs/python-ovos-stt-plugin-pocketsphinx/*.pkg.tar.zst

python-ovos-stt-plugin-selene: python-ovos-utils python-ovos-backend-client python-ovos-plugin-manager PKGBUILDs/python-ovos-stt-plugin-selene/*.pkg.tar.zst

python-ovos-stt-plugin-server: python-ovos-plugin-manager PKGBUILDs/python-ovos-stt-plugin-server/*.pkg.tar.zst

python-ovos-stt-plugin-vosk: python-ovos-skill-installer python-ovos-plugin-manager python-speechrecognition python-vosk PKGBUILDs/python-ovos-stt-plugin-vosk/*.pkg.tar.zst

python-ovos-stt-plugin-whispercpp: python-ovos-plugin-manager python-speechrecognition PKGBUILDs/python-ovos-stt-plugin-whispercpp/*.pkg.tar.zst

python-ovos-tts-plugin-marytts:  PKGBUILDs/python-ovos-tts-plugin-marytts/*.pkg.tar.zst

python-ovos-tts-plugin-mimic: mycroft-mimic1 python-ovos-plugin-manager PKGBUILDs/python-ovos-tts-plugin-mimic/*.pkg.tar.zst

python-ovos-tts-plugin-mimic2: python-ovos-plugin-manager python-ovos-utils PKGBUILDs/python-ovos-tts-plugin-mimic2/*.pkg.tar.zst

python-ovos-tts-plugin-mimic3: python-ovos-plugin-manager python-ovos-utils python-mycroft-mimic3-tts PKGBUILDs/python-ovos-tts-plugin-mimic3/*.pkg.tar.zst

python-ovos-tts-plugin-mimic3-server: python-ovos-plugin-manager python-ovos-utils PKGBUILDs/python-ovos-tts-plugin-mimic3-server/*.pkg.tar.zst

python-ovos-tts-plugin-pico: python-ovos-plugin-manager PKGBUILDs/python-ovos-tts-plugin-pico/*.pkg.tar.zst

python-ovos-tts-server: python-ovos-plugin-manager python-ovos-utils python-uvicorn PKGBUILDs/python-ovos-tts-server/*.pkg.tar.zst

python-ovos-tts-server-plugin: python-ovos-plugin-manager PKGBUILDs/python-ovos-tts-server-plugin/*.pkg.tar.zst

python-ovos-utils: python-json-database python-kthread PKGBUILDs/python-ovos-utils/*.pkg.tar.zst

python-ovos-vad-plugin-webrtcvad: python-ovos-plugin-manager PKGBUILDs/python-ovos-vad-plugin-webrtcvad/*.pkg.tar.zst

python-ovos-vlc-plugin: python-ovos-plugin-manager python-vlc PKGBUILDs/python-ovos-vlc-plugin/*.pkg.tar.zst

python-ovos-workshop: python-ovos-backend-client python-ovos-config python-ovos-bus-client python-ovos-lingua-franca python-ovos-utils PKGBUILDs/python-ovos-workshop/*.pkg.tar.zst

python-ovos-ww-plugin-pocketsphinx: python-ovos-plugin-manager python-phoneme-guesser python-pocketsphinx python-speechrecognition PKGBUILDs/python-ovos-ww-plugin-pocketsphinx/*.pkg.tar.zst

python-ovos-ww-plugin-precise: python-ovos-plugin-manager python-ovos-utils python-petact python-precise-runner PKGBUILDs/python-ovos-ww-plugin-precise/*.pkg.tar.zst

python-ovos-ww-plugin-precise-lite: ovos-precise-lite-models python-ovos-plugin-manager python-ovos-utils python-precise-lite-runner PKGBUILDs/python-ovos-ww-plugin-precise-lite/*.pkg.tar.zst

python-ovos-ww-plugin-vosk: python-ovos-plugin-manager python-ovos-skill-installer python-vosk PKGBUILDs/python-ovos-ww-plugin-vosk/*.pkg.tar.zst

python-padacioso: python-simplematch PKGBUILDs/python-padacioso/*.pkg.tar.zst

python-pako:  PKGBUILDs-extra/python-pako/*.pkg.tar.zst

python-panphon: aur-repo python-unicodecsv AUR/python-panphon/*.pkg.tar.zst

python-petact:  PKGBUILDs-extra/python-petact/*.pkg.tar.zst

python-phoneme-guesser:  PKGBUILDs-extra/python-phoneme-guesser/*.pkg.tar.zst

python-phonemes2ids: aur-repo AUR/python-phonemes2ids/*.pkg.tar.zst

python-pocketsphinx:  PKGBUILDs-extra/python-pocketsphinx/*.pkg.tar.zst

python-pprintpp:  PKGBUILDs-extra/python-pprintpp/*.pkg.tar.zst

python-precise-lite-runner: python-sonopy python-tflite-runtime PKGBUILDs-extra/python-precise-lite-runner/*.pkg.tar.zst

python-precise-runner:  PKGBUILDs-extra/python-precise-runner/*.pkg.tar.zst

python-py-bandcamp: python-requests-cache PKGBUILDs-extra/python-py-bandcamp/*.pkg.tar.zst

python-pyalsaaudio:  PKGBUILDs-extra/python-pyalsaaudio/*.pkg.tar.zst

python-pytube:  PKGBUILDs-extra/python-pytube/*.pkg.tar.zst

python-pywebio:  PKGBUILDs-extra/python-pywebio/*.pkg.tar.zst

python-quebra-frases:  PKGBUILDs-extra/python-quebra-frases/*.pkg.tar.zst

python-requests-cache: python-cattrs python-url-normalize PKGBUILDs-extra/python-requests-cache/*.pkg.tar.zst

python-rich-click:  PKGBUILDs-extra/python-rich-click/*.pkg.tar.zst

python-rpi.gpio:  PKGBUILDs-extra/python-rpi.gpio/*.pkg.tar.zst

python-sdnotify:  PKGBUILDs-extra/python-sdnotify/*.pkg.tar.zst

python-simplematch:  PKGBUILDs-extra/python-simplematch/*.pkg.tar.zst

python-smbus2:  PKGBUILDs-extra/python-smbus2/*.pkg.tar.zst

python-sonopy:  PKGBUILDs-extra/python-sonopy/*.pkg.tar.zst

python-speechrecognition:  PKGBUILDs-extra/python-speechrecognition/*.pkg.tar.zst

python-spidev:  PKGBUILDs-extra/python-spidev/*.pkg.tar.zst

python-sqlalchemy-json:  PKGBUILDs-extra/python-sqlalchemy-json/*.pkg.tar.zst

python-srt:  PKGBUILDs-extra/python-srt/*.pkg.tar.zst

python-tflite-runtime:  PKGBUILDs-extra/python-tflite-runtime/*.pkg.tar.zst

python-timezonefinder: python-h3 PKGBUILDs-extra/python-timezonefinder/*.pkg.tar.zst

python-tutubo: python-bs4 python-pytube PKGBUILDs-extra/python-tutubo/*.pkg.tar.zst

python-tzlocal:  PKGBUILDs-extra/python-tzlocal/*.pkg.tar.zst

python-unicodecsv: aur-repo AUR/python-unicodecsv/*.pkg.tar.zst

python-url-normalize:  PKGBUILDs-extra/python-url-normalize/*.pkg.tar.zst

python-uvicorn:  PKGBUILDs-extra/python-uvicorn/*.pkg.tar.zst

python-vlc:  PKGBUILDs-extra/python-vlc/*.pkg.tar.zst

python-vosk: python-srt PKGBUILDs-extra/python-vosk/*.pkg.tar.zst

python-wallpaper-finder: python-bs4 python-requests-cache PKGBUILDs-extra/python-wallpaper-finder/*.pkg.tar.zst

python-xdgenvpy: aur-repo AUR/python-xdgenvpy/*.pkg.tar.zst

python-youtube-search:  PKGBUILDs-extra/python-youtube-search/*.pkg.tar.zst

python-yt-dlp:  PKGBUILDs-extra/python-yt-dlp/*.pkg.tar.zst

mycroft-gui-qt6-git: # Ignored
