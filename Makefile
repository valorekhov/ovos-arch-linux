.PHONY: all clean extra
RUN_MAKEPKG := makepkg --syncdeps --noconfirm --force --install

OVOS_PACKAGES := $(notdir $(wildcard PKGBUILDs/*))

EXTRA_PACKAGES := $(notdir $(wildcard PKGBUILDs-extra/*))

ALL_PACKAGES := $(OVOS_PACKAGES) + $(EXTRA_PACKAGES)

# The default target will build all OVOS packages and only those 'extra' dependent packages which are in use
all: $(OVOS_PACKAGES)

extra: $(EXTRA_PACKAGES)

clean:
	@rm -rf ./{PKGBUILDs,PKGBUILDs-extra}/*/pkg ./{PKGBUILDs,PKGBUILDs-extra}/*/src ./{PKGBUILDs,PKGBUILDs-extra}/*/*.pkg.tar*

uninstall:
	@pacman -Qq | sort | comm -12 - <(echo "$(ALL_PACKAGES)" | tr ' ' '\n' | sort) | xargs sudo pacman -Rcns --noconfirm
%.pkg.tar.zst:
	$(eval DIR := $(shell echo '$*' | cut -d* -f1))
	@echo 'Building $(DIR)'
	@cd $(DIR) && $(RUN_MAKEPKG)


mycroft-gui:  PKGBUILDs/mycroft-gui/*.pkg.tar.zst

ovos-bus-server:  PKGBUILDs/ovos-bus-server/*.pkg.tar.zst

ovos-dashboard:  PKGBUILDs/ovos-dashboard/*.pkg.tar.zst

ovos-enclosure-rpi4-mark2:  PKGBUILDs/ovos-enclosure-rpi4-mark2/*.pkg.tar.zst

ovos-enclosure-rpi4-mark2-sj201-r10:  PKGBUILDs/ovos-enclosure-rpi4-mark2-sj201-r10/*.pkg.tar.zst

ovos-service-base:  PKGBUILDs/ovos-service-base/*.pkg.tar.zst

ovos-shell: PKGBUILDs/mycroft-gui/*.pkg.tar.zst PKGBUILDs/ovos-shell/*.pkg.tar.zst

ovos-shell-standalone: PKGBUILDs/ovos-service-base/*.pkg.tar.zst PKGBUILDs/ovos-shell/*.pkg.tar.zst PKGBUILDs/ovos-shell-standalone/*.pkg.tar.zst

ovos-splash:  PKGBUILDs/ovos-splash/*.pkg.tar.zst

python-adapt-parser:  PKGBUILDs-extra/python-adapt-parser/*.pkg.tar.zst

python-bitstruct:  PKGBUILDs-extra/python-bitstruct/*.pkg.tar.zst

python-bs4:  PKGBUILDs-extra/python-bs4/*.pkg.tar.zst

python-combo-lock:  PKGBUILDs-extra/python-combo-lock/*.pkg.tar.zst

python-cutecharts:  PKGBUILDs-extra/python-cutecharts/*.pkg.tar.zst

python-deezeridu:  PKGBUILDs-extra/python-deezeridu/*.pkg.tar.zst

python-gradio:  PKGBUILDs-extra/python-gradio/*.pkg.tar.zst

python-json-database:  PKGBUILDs-extra/python-json-database/*.pkg.tar.zst

python-kthread:  PKGBUILDs-extra/python-kthread/*.pkg.tar.zst

python-langcodes:  PKGBUILDs-extra/python-langcodes/*.pkg.tar.zst

python-mycroft-messagebus-client:  PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst

python-nested-lookup:  PKGBUILDs-extra/python-nested-lookup/*.pkg.tar.zst

python-ovos-audio: PKGBUILDs/python-ovos-plugin-common-play/*.pkg.tar.zst PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-files-plugin/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-m3u-plugin/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-news-plugin/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-rss-plugin/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-tts-plugin-mimic3-server/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-audio/*.pkg.tar.zst

python-ovos-audio-plugin-simple: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-audio-plugin-simple/*.pkg.tar.zst

python-ovos-backend-client: PKGBUILDs-extra/python-json-database/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-backend-client/*.pkg.tar.zst

python-ovos-backend-manager: PKGBUILDs-extra/python-cutecharts/*.pkg.tar.zst PKGBUILDs/python-ovos-local-backend/*.pkg.tar.zst PKGBUILDs-extra/python-pywebio/*.pkg.tar.zst PKGBUILDs/python-ovos-backend-manager/*.pkg.tar.zst

python-ovos-bus-client: PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst

python-ovos-classifiers: PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-classifiers/*.pkg.tar.zst

python-ovos-cli-client: PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-cli-client/*.pkg.tar.zst

python-ovos-config: PKGBUILDs-extra/python-combo-lock/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs-extra/python-rich-click/*.pkg.tar.zst PKGBUILDs/python-ovos-config/*.pkg.tar.zst

python-ovos-config-assistant: PKGBUILDs-extra/python-cutecharts/*.pkg.tar.zst PKGBUILDs/python-ovos-backend-client/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs-extra/python-pywebio/*.pkg.tar.zst PKGBUILDs/python-ovos-config-assistant/*.pkg.tar.zst

python-ovos-core: PKGBUILDs-extra/python-adapt-parser/*.pkg.tar.zst PKGBUILDs-extra/python-combo-lock/*.pkg.tar.zst PKGBUILDs/python-ovos-backend-client/*.pkg.tar.zst PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-workshop/*.pkg.tar.zst PKGBUILDs/python-ovos-classifiers/*.pkg.tar.zst PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-lingua-franca/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs-extra/python-padacioso/*.pkg.tar.zst PKGBUILDs/python-ovos-core/*.pkg.tar.zst

python-ovos-gui: PKGBUILDs/python-ovos-backend-client/*.pkg.tar.zst PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-gui/*.pkg.tar.zst

python-ovos-lingua-franca: PKGBUILDs-extra/python-quebra-frases/*.pkg.tar.zst PKGBUILDs/python-ovos-lingua-franca/*.pkg.tar.zst

python-ovos-listener: PKGBUILDs/python-ovos-backend-client/*.pkg.tar.zst PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-stt-plugin-server/*.pkg.tar.zst PKGBUILDs/python-ovos-stt-plugin-vosk/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-vad-plugin-webrtcvad/*.pkg.tar.zst PKGBUILDs/python-ovos-ww-plugin-pocketsphinx/*.pkg.tar.zst PKGBUILDs/python-ovos-ww-plugin-precise-lite/*.pkg.tar.zst PKGBUILDs/python-ovos-ww-plugin-vosk/*.pkg.tar.zst PKGBUILDs-extra/python-speechrecognition/*.pkg.tar.zst PKGBUILDs/python-ovos-listener/*.pkg.tar.zst

python-ovos-local-backend:  PKGBUILDs/python-ovos-local-backend/*.pkg.tar.zst

python-ovos-messagebus: PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-messagebus/*.pkg.tar.zst

python-ovos-notifications-service: PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-notifications-service/*.pkg.tar.zst

python-ovos-ocp-audio-plugin: PKGBUILDs/python-ovos-audio-plugin-simple/*.pkg.tar.zst PKGBUILDs/python-ovos-workshop/*.pkg.tar.zst PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-files-plugin/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs-extra/python-padacioso/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-audio-plugin/*.pkg.tar.zst

python-ovos-ocp-bandcamp-plugin: PKGBUILDs/python-ovos-plugin-common-play/*.pkg.tar.zst PKGBUILDs-extra/python-py-bandcamp/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-bandcamp-plugin/*.pkg.tar.zst

python-ovos-ocp-deezer-plugin: PKGBUILDs-extra/python-deezeridu/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-common-play/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-deezer-plugin/*.pkg.tar.zst

python-ovos-ocp-files-plugin: PKGBUILDs-extra/python-bitstruct/*.pkg.tar.zst PKGBUILDs-extra/python-pprintpp/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-files-plugin/*.pkg.tar.zst

python-ovos-ocp-m3u-plugin: PKGBUILDs/python-ovos-plugin-common-play/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-m3u-plugin/*.pkg.tar.zst

python-ovos-ocp-news-plugin: PKGBUILDs/python-ovos-plugin-common-play/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-m3u-plugin/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-rss-plugin/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-news-plugin/*.pkg.tar.zst

python-ovos-ocp-rss-plugin: PKGBUILDs/python-ovos-plugin-common-play/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-rss-plugin/*.pkg.tar.zst

python-ovos-ocp-youtube-plugin: PKGBUILDs/python-ovos-plugin-common-play/*.pkg.tar.zst PKGBUILDs-extra/python-tutubo/*.pkg.tar.zst PKGBUILDs-extra/python-yt-dlp/*.pkg.tar.zst PKGBUILDs/python-ovos-ocp-youtube-plugin/*.pkg.tar.zst

python-ovos-personal-backend: PKGBUILDs-extra/python-json-database/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-stt-plugin-server/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs-extra/python-requests-cache/*.pkg.tar.zst PKGBUILDs-extra/python-sqlalchemy-json/*.pkg.tar.zst PKGBUILDs-extra/python-timezonefinder/*.pkg.tar.zst PKGBUILDs/python-ovos-personal-backend/*.pkg.tar.zst

python-ovos-phal: PKGBUILDs/python-ovos-workshop/*.pkg.tar.zst PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-connectivity-events/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-ipgeo/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-network-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-oauth/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-system/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-phal/*.pkg.tar.zst

python-ovos-phal-plugin-alsa: PKGBUILDs-extra/python-json-database/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs-extra/python-pyalsaaudio/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-alsa/*.pkg.tar.zst

python-ovos-phal-plugin-balena-wifi: PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-balena-wifi/*.pkg.tar.zst

python-ovos-phal-plugin-brightness-control-rpi: PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-brightness-control-rpi/*.pkg.tar.zst

python-ovos-phal-plugin-color-scheme-manager: PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-color-scheme-manager/*.pkg.tar.zst

python-ovos-phal-plugin-configuration-provider: PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-configuration-provider/*.pkg.tar.zst

python-ovos-phal-plugin-connectivity-events: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-connectivity-events/*.pkg.tar.zst

python-ovos-phal-plugin-dashboard: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-dashboard/*.pkg.tar.zst

python-ovos-phal-plugin-display-manager-ipc:  PKGBUILDs/python-ovos-phal-plugin-display-manager-ipc/*.pkg.tar.zst

python-ovos-phal-plugin-gpsd:  PKGBUILDs/python-ovos-phal-plugin-gpsd/*.pkg.tar.zst

python-ovos-phal-plugin-gui-network-client: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-gui-network-client/*.pkg.tar.zst

python-ovos-phal-plugin-homeassistant: PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst PKGBUILDs-extra/python-nested-lookup/*.pkg.tar.zst PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-oauth/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs-extra/python-pytube/*.pkg.tar.zst PKGBUILDs-extra/python-youtube-search/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-homeassistant/*.pkg.tar.zst

python-ovos-phal-plugin-ipgeo: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-ipgeo/*.pkg.tar.zst

python-ovos-phal-plugin-mk1:  PKGBUILDs/python-ovos-phal-plugin-mk1/*.pkg.tar.zst

python-ovos-phal-plugin-mk2: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs-extra/python-rpi.gpio/*.pkg.tar.zst PKGBUILDs-extra/python-smbus2/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-mk2/*.pkg.tar.zst

python-ovos-phal-plugin-network-manager: PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-network-manager/*.pkg.tar.zst

python-ovos-phal-plugin-notification-widgets: PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-notification-widgets/*.pkg.tar.zst

python-ovos-phal-plugin-oauth: PKGBUILDs/python-ovos-backend-client/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-oauth/*.pkg.tar.zst

python-ovos-phal-plugin-respeaker-2mic:  PKGBUILDs/python-ovos-phal-plugin-respeaker-2mic/*.pkg.tar.zst

python-ovos-phal-plugin-respeaker-4mic:  PKGBUILDs/python-ovos-phal-plugin-respeaker-4mic/*.pkg.tar.zst

python-ovos-phal-plugin-system: PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-system/*.pkg.tar.zst

python-ovos-phal-plugin-wifi-setup: PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-phal-plugin-wifi-setup/*.pkg.tar.zst

python-ovos-plugin-common-play:  PKGBUILDs/python-ovos-plugin-common-play/*.pkg.tar.zst

python-ovos-plugin-manager: PKGBUILDs-extra/python-combo-lock/*.pkg.tar.zst PKGBUILDs-extra/python-langcodes/*.pkg.tar.zst PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs-extra/python-quebra-frases/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst

python-ovos-skill-installer:  PKGBUILDs/python-ovos-skill-installer/*.pkg.tar.zst

python-ovos-skill-manager: PKGBUILDs-extra/python-bs4/*.pkg.tar.zst PKGBUILDs-extra/python-combo-lock/*.pkg.tar.zst PKGBUILDs-extra/python-json-database/*.pkg.tar.zst PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-skill-installer/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs-extra/python-pako/*.pkg.tar.zst PKGBUILDs-extra/python-requests-cache/*.pkg.tar.zst PKGBUILDs/python-ovos-skill-manager/*.pkg.tar.zst

python-ovos-stt-http-server: PKGBUILDs-extra/python-gradio/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs-extra/python-uvicorn/*.pkg.tar.zst PKGBUILDs/python-ovos-stt-http-server/*.pkg.tar.zst

python-ovos-stt-plugin-chromium: PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-stt-plugin-chromium/*.pkg.tar.zst

python-ovos-stt-plugin-pocketsphinx: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs-extra/python-pocketsphinx/*.pkg.tar.zst PKGBUILDs-extra/python-speechrecognition/*.pkg.tar.zst PKGBUILDs/python-ovos-stt-plugin-pocketsphinx/*.pkg.tar.zst

python-ovos-stt-plugin-selene: PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-backend-client/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-stt-plugin-selene/*.pkg.tar.zst

python-ovos-stt-plugin-server: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-stt-plugin-server/*.pkg.tar.zst

python-ovos-stt-plugin-vosk: PKGBUILDs/python-ovos-skill-installer/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs-extra/python-speechrecognition/*.pkg.tar.zst PKGBUILDs-extra/python-vosk/*.pkg.tar.zst PKGBUILDs/python-ovos-stt-plugin-vosk/*.pkg.tar.zst

python-ovos-stt-plugin-whispercpp: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs-extra/python-speechrecognition/*.pkg.tar.zst PKGBUILDs/python-ovos-stt-plugin-whispercpp/*.pkg.tar.zst

python-ovos-tts-plugin-marytts:  PKGBUILDs/python-ovos-tts-plugin-marytts/*.pkg.tar.zst

python-ovos-tts-plugin-mimic: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-tts-plugin-mimic/*.pkg.tar.zst

python-ovos-tts-plugin-mimic2: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-tts-plugin-mimic2/*.pkg.tar.zst

python-ovos-tts-plugin-mimic3-server: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-tts-plugin-mimic3-server/*.pkg.tar.zst

python-ovos-tts-plugin-pico: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-tts-plugin-pico/*.pkg.tar.zst

python-ovos-tts-server: PKGBUILDs-extra/python-gradio/*.pkg.tar.zst PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs-extra/python-uvicorn/*.pkg.tar.zst PKGBUILDs/python-ovos-tts-server/*.pkg.tar.zst

python-ovos-tts-server-plugin: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-tts-server-plugin/*.pkg.tar.zst

python-ovos-utils: PKGBUILDs-extra/python-json-database/*.pkg.tar.zst PKGBUILDs-extra/python-kthread/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst

python-ovos-vad-plugin-webrtcvad: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-vad-plugin-webrtcvad/*.pkg.tar.zst

python-ovos-vlc-plugin: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs-extra/python-vlc/*.pkg.tar.zst PKGBUILDs/python-ovos-vlc-plugin/*.pkg.tar.zst

python-ovos-workshop: PKGBUILDs/python-ovos-backend-client/*.pkg.tar.zst PKGBUILDs/python-ovos-config/*.pkg.tar.zst PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst PKGBUILDs/python-ovos-lingua-franca/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-workshop/*.pkg.tar.zst

python-ovos-ww-plugin-pocketsphinx: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs-extra/python-phoneme-guesser/*.pkg.tar.zst PKGBUILDs-extra/python-pocketsphinx/*.pkg.tar.zst PKGBUILDs-extra/python-speechrecognition/*.pkg.tar.zst PKGBUILDs/python-ovos-ww-plugin-pocketsphinx/*.pkg.tar.zst

python-ovos-ww-plugin-precise: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs-extra/python-petact/*.pkg.tar.zst PKGBUILDs-extra/python-precise-runner/*.pkg.tar.zst PKGBUILDs/python-ovos-ww-plugin-precise/*.pkg.tar.zst

python-ovos-ww-plugin-precise-lite: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-utils/*.pkg.tar.zst PKGBUILDs/python-ovos-ww-plugin-precise-lite/*.pkg.tar.zst

python-ovos-ww-plugin-vosk: PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst PKGBUILDs/python-ovos-skill-installer/*.pkg.tar.zst PKGBUILDs-extra/python-vosk/*.pkg.tar.zst PKGBUILDs/python-ovos-ww-plugin-vosk/*.pkg.tar.zst

python-padacioso:  PKGBUILDs-extra/python-padacioso/*.pkg.tar.zst

python-pako:  PKGBUILDs-extra/python-pako/*.pkg.tar.zst

python-petact:  PKGBUILDs-extra/python-petact/*.pkg.tar.zst

python-phoneme-guesser:  PKGBUILDs-extra/python-phoneme-guesser/*.pkg.tar.zst

python-pocketsphinx:  PKGBUILDs-extra/python-pocketsphinx/*.pkg.tar.zst

python-pprintpp:  PKGBUILDs-extra/python-pprintpp/*.pkg.tar.zst

python-precise-runner:  PKGBUILDs-extra/python-precise-runner/*.pkg.tar.zst

python-py-bandcamp:  PKGBUILDs-extra/python-py-bandcamp/*.pkg.tar.zst

python-pyalsaaudio:  PKGBUILDs-extra/python-pyalsaaudio/*.pkg.tar.zst

python-pytube:  PKGBUILDs-extra/python-pytube/*.pkg.tar.zst

python-pywebio:  PKGBUILDs-extra/python-pywebio/*.pkg.tar.zst

python-quebra-frases:  PKGBUILDs-extra/python-quebra-frases/*.pkg.tar.zst

python-requests-cache:  PKGBUILDs-extra/python-requests-cache/*.pkg.tar.zst

python-rich-click:  PKGBUILDs-extra/python-rich-click/*.pkg.tar.zst

python-rpi.gpio:  PKGBUILDs-extra/python-rpi.gpio/*.pkg.tar.zst

python-smbus2:  PKGBUILDs-extra/python-smbus2/*.pkg.tar.zst

python-speechrecognition:  PKGBUILDs-extra/python-speechrecognition/*.pkg.tar.zst

python-sqlalchemy-json:  PKGBUILDs-extra/python-sqlalchemy-json/*.pkg.tar.zst

python-timezonefinder:  PKGBUILDs-extra/python-timezonefinder/*.pkg.tar.zst

python-tutubo:  PKGBUILDs-extra/python-tutubo/*.pkg.tar.zst

python-uvicorn:  PKGBUILDs-extra/python-uvicorn/*.pkg.tar.zst

python-vlc:  PKGBUILDs-extra/python-vlc/*.pkg.tar.zst

python-vosk:  PKGBUILDs-extra/python-vosk/*.pkg.tar.zst

python-youtube-search:  PKGBUILDs-extra/python-youtube-search/*.pkg.tar.zst

python-yt-dlp:  PKGBUILDs-extra/python-yt-dlp/*.pkg.tar.zst
