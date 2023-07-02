.PHONY: all clean extra
RUN_MAKEPKG := makepkg --syncdeps --noconfirm --force --install

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
	@rm -rf ./{PKGBUILDs,PKGBUILDs-extra}/*/*.pkg.tar*

uninstall:
	@pacman -Qq | sort | comm -12 - <(echo "$(ALL_PACKAGES)" | tr ' ' '\n' | sort) | xargs sudo pacman -Rcns --noconfirm

%.pkg.tar.zst:
	$(eval DIR := $(shell echo '$*' | cut -d* -f1))
	@echo 'Building $(DIR)'
	@cd $(DIR) && $(RUN_MAKEPKG)


mycroft-gui:  PKGBUILDs/mycroft-gui/*.pkg.tar.zst

ovos-bus-server:  PKGBUILDs/ovos-bus-server/*.pkg.tar.zst

ovos-core: python-ovos-core ovos-service-base PKGBUILDs/ovos-core/*.pkg.tar.zst

ovos-dashboard:  PKGBUILDs/ovos-dashboard/*.pkg.tar.zst

ovos-enclosure-rpi4-mark2:  PKGBUILDs/ovos-enclosure-rpi4-mark2/*.pkg.tar.zst

ovos-enclosure-rpi4-mark2-sj201-r10:  PKGBUILDs/ovos-enclosure-rpi4-mark2-sj201-r10/*.pkg.tar.zst

ovos-service-base:  PKGBUILDs/ovos-service-base/*.pkg.tar.zst

ovos-shell: mycroft-gui PKGBUILDs/ovos-shell/*.pkg.tar.zst

ovos-shell-standalone: ovos-service-base ovos-shell PKGBUILDs/ovos-shell-standalone/*.pkg.tar.zst

ovos-splash:  PKGBUILDs/ovos-splash/*.pkg.tar.zst

python-adapt-parser:  PKGBUILDs-extra/python-adapt-parser/*.pkg.tar.zst

python-bitstruct:  PKGBUILDs-extra/python-bitstruct/*.pkg.tar.zst

python-bs4:  PKGBUILDs-extra/python-bs4/*.pkg.tar.zst

python-cattrs:  PKGBUILDs-extra/python-cattrs/*.pkg.tar.zst

python-combo-lock: python-filelock python-memory-tempfile PKGBUILDs-extra/python-combo-lock/*.pkg.tar.zst

python-cutecharts:  PKGBUILDs-extra/python-cutecharts/*.pkg.tar.zst

python-deezeridu:  PKGBUILDs-extra/python-deezeridu/*.pkg.tar.zst

python-filelock:  PKGBUILDs-extra/python-filelock/*.pkg.tar.zst

python-gradio: python-uvicorn PKGBUILDs-extra/python-gradio/*.pkg.tar.zst

python-h3:  PKGBUILDs-extra/python-h3/*.pkg.tar.zst

python-json-database: python-combo-lock PKGBUILDs-extra/python-json-database/*.pkg.tar.zst

python-kthread:  PKGBUILDs-extra/python-kthread/*.pkg.tar.zst

python-langcodes:  PKGBUILDs-extra/python-langcodes/*.pkg.tar.zst

python-memory-tempfile:  PKGBUILDs-extra/python-memory-tempfile/*.pkg.tar.zst

python-mycroft-messagebus-client:  PKGBUILDs/python-mycroft-messagebus-client/*.pkg.tar.zst

python-nested-lookup:  PKGBUILDs-extra/python-nested-lookup/*.pkg.tar.zst

python-ovos-audio: python-ovos-ocp-audio-plugin python-ovos-bus-client python-ovos-config python-ovos-ocp-files-plugin python-ovos-ocp-m3u-plugin python-ovos-ocp-news-plugin python-ovos-ocp-rss-plugin python-ovos-plugin-manager python-ovos-tts-plugin-mimic3-server python-ovos-utils PKGBUILDs/python-ovos-audio/*.pkg.tar.zst

python-ovos-audio-plugin-simple: python-ovos-plugin-manager PKGBUILDs/python-ovos-audio-plugin-simple/*.pkg.tar.zst

python-ovos-backend-client: python-json-database python-ovos-utils PKGBUILDs/python-ovos-backend-client/*.pkg.tar.zst

python-ovos-backend-manager: python-cutecharts python-ovos-personal-backend python-pywebio PKGBUILDs/python-ovos-backend-manager/*.pkg.tar.zst

python-ovos-bus-client: python-ovos-config python-ovos-utils PKGBUILDs/python-ovos-bus-client/*.pkg.tar.zst

python-ovos-classifiers: python-ovos-utils PKGBUILDs/python-ovos-classifiers/*.pkg.tar.zst

python-ovos-cli-client: python-ovos-utils python-ovos-bus-client PKGBUILDs/python-ovos-cli-client/*.pkg.tar.zst

python-ovos-config: python-combo-lock python-ovos-utils python-rich-click PKGBUILDs/python-ovos-config/*.pkg.tar.zst

python-ovos-config-assistant: python-cutecharts python-ovos-backend-client python-ovos-utils python-pywebio PKGBUILDs/python-ovos-config-assistant/*.pkg.tar.zst

python-ovos-core: python-adapt-parser python-combo-lock python-ovos-backend-client python-ovos-bus-client python-ovos-workshop python-ovos-classifiers python-ovos-config python-ovos-lingua-franca python-ovos-plugin-manager python-ovos-utils python-padacioso PKGBUILDs/python-ovos-core/*.pkg.tar.zst

python-ovos-gui: python-ovos-backend-client python-ovos-bus-client python-ovos-config python-ovos-utils PKGBUILDs/python-ovos-gui/*.pkg.tar.zst

python-ovos-lingua-franca: python-quebra-frases PKGBUILDs/python-ovos-lingua-franca/*.pkg.tar.zst

python-ovos-listener: python-ovos-backend-client python-ovos-bus-client python-ovos-config python-ovos-plugin-manager python-ovos-stt-plugin-server python-ovos-stt-plugin-vosk python-ovos-utils python-ovos-vad-plugin-webrtcvad python-ovos-ww-plugin-pocketsphinx python-ovos-ww-plugin-precise-lite python-ovos-ww-plugin-vosk python-speechrecognition PKGBUILDs/python-ovos-listener/*.pkg.tar.zst

python-ovos-messagebus: python-ovos-config python-ovos-utils PKGBUILDs/python-ovos-messagebus/*.pkg.tar.zst

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

python-ovos-phal: python-ovos-workshop python-ovos-bus-client python-ovos-config python-ovos-phal-plugin-connectivity-events python-ovos-phal-plugin-ipgeo python-ovos-phal-plugin-network-manager python-ovos-phal-plugin-oauth python-ovos-phal-plugin-system python-ovos-plugin-manager python-ovos-utils PKGBUILDs/python-ovos-phal/*.pkg.tar.zst

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

python-ovos-phal-plugin-wifi-setup: python-mycroft-messagebus-client python-ovos-utils python-ovos-plugin-manager PKGBUILDs/python-ovos-phal-plugin-wifi-setup/*.pkg.tar.zst

python-ovos-plugin-manager: python-combo-lock python-langcodes python-ovos-bus-client python-ovos-config python-ovos-utils python-quebra-frases PKGBUILDs/python-ovos-plugin-manager/*.pkg.tar.zst

python-ovos-skill-installer:  PKGBUILDs/python-ovos-skill-installer/*.pkg.tar.zst

python-ovos-skill-manager: python-bs4 python-combo-lock python-json-database python-ovos-config python-ovos-skill-installer python-ovos-utils python-pako python-requests-cache PKGBUILDs/python-ovos-skill-manager/*.pkg.tar.zst

python-ovos-stt-http-server: python-ovos-plugin-manager python-ovos-utils python-uvicorn PKGBUILDs/python-ovos-stt-http-server/*.pkg.tar.zst

python-ovos-stt-plugin-chromium: python-ovos-utils python-ovos-plugin-manager PKGBUILDs/python-ovos-stt-plugin-chromium/*.pkg.tar.zst

python-ovos-stt-plugin-pocketsphinx: python-ovos-plugin-manager python-pocketsphinx python-speechrecognition PKGBUILDs/python-ovos-stt-plugin-pocketsphinx/*.pkg.tar.zst

python-ovos-stt-plugin-selene: python-ovos-utils python-ovos-backend-client python-ovos-plugin-manager PKGBUILDs/python-ovos-stt-plugin-selene/*.pkg.tar.zst

python-ovos-stt-plugin-server: python-ovos-plugin-manager PKGBUILDs/python-ovos-stt-plugin-server/*.pkg.tar.zst

python-ovos-stt-plugin-vosk: python-ovos-skill-installer python-ovos-plugin-manager python-speechrecognition python-vosk PKGBUILDs/python-ovos-stt-plugin-vosk/*.pkg.tar.zst

python-ovos-stt-plugin-whispercpp: python-ovos-plugin-manager python-speechrecognition PKGBUILDs/python-ovos-stt-plugin-whispercpp/*.pkg.tar.zst

python-ovos-tts-plugin-marytts:  PKGBUILDs/python-ovos-tts-plugin-marytts/*.pkg.tar.zst

python-ovos-tts-plugin-mimic: python-ovos-plugin-manager PKGBUILDs/python-ovos-tts-plugin-mimic/*.pkg.tar.zst

python-ovos-tts-plugin-mimic2: python-ovos-plugin-manager python-ovos-utils PKGBUILDs/python-ovos-tts-plugin-mimic2/*.pkg.tar.zst

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

python-ovos-ww-plugin-precise-lite: python-ovos-plugin-manager python-ovos-utils python-precise-lite-runner PKGBUILDs/python-ovos-ww-plugin-precise-lite/*.pkg.tar.zst

python-ovos-ww-plugin-vosk: python-ovos-plugin-manager python-ovos-skill-installer python-vosk PKGBUILDs/python-ovos-ww-plugin-vosk/*.pkg.tar.zst

python-padacioso: python-simplematch PKGBUILDs-extra/python-padacioso/*.pkg.tar.zst

python-pako:  PKGBUILDs-extra/python-pako/*.pkg.tar.zst

python-petact:  PKGBUILDs-extra/python-petact/*.pkg.tar.zst

python-phoneme-guesser:  PKGBUILDs-extra/python-phoneme-guesser/*.pkg.tar.zst

python-pocketsphinx:  PKGBUILDs-extra/python-pocketsphinx/*.pkg.tar.zst

python-pprintpp:  PKGBUILDs-extra/python-pprintpp/*.pkg.tar.zst

python-precise-lite-runner: python-sonopy PKGBUILDs-extra/python-precise-lite-runner/*.pkg.tar.zst

python-precise-runner:  PKGBUILDs-extra/python-precise-runner/*.pkg.tar.zst

python-py-bandcamp: python-requests-cache PKGBUILDs-extra/python-py-bandcamp/*.pkg.tar.zst

python-pyalsaaudio:  PKGBUILDs-extra/python-pyalsaaudio/*.pkg.tar.zst

python-pytube:  PKGBUILDs-extra/python-pytube/*.pkg.tar.zst

python-pywebio:  PKGBUILDs-extra/python-pywebio/*.pkg.tar.zst

python-quebra-frases:  PKGBUILDs-extra/python-quebra-frases/*.pkg.tar.zst

python-requests-cache: python-cattrs python-url-normalize PKGBUILDs-extra/python-requests-cache/*.pkg.tar.zst

python-rich-click:  PKGBUILDs-extra/python-rich-click/*.pkg.tar.zst

python-rpi.gpio:  PKGBUILDs-extra/python-rpi.gpio/*.pkg.tar.zst

python-simplematch:  PKGBUILDs-extra/python-simplematch/*.pkg.tar.zst

python-smbus2:  PKGBUILDs-extra/python-smbus2/*.pkg.tar.zst

python-sonopy:  PKGBUILDs-extra/python-sonopy/*.pkg.tar.zst

python-speechrecognition:  PKGBUILDs-extra/python-speechrecognition/*.pkg.tar.zst

python-sqlalchemy-json:  PKGBUILDs-extra/python-sqlalchemy-json/*.pkg.tar.zst

python-srt:  PKGBUILDs-extra/python-srt/*.pkg.tar.zst

python-timezonefinder: python-h3 PKGBUILDs-extra/python-timezonefinder/*.pkg.tar.zst

python-tutubo: python-bs4 python-pytube PKGBUILDs-extra/python-tutubo/*.pkg.tar.zst

python-url-normalize:  PKGBUILDs-extra/python-url-normalize/*.pkg.tar.zst

python-uvicorn:  PKGBUILDs-extra/python-uvicorn/*.pkg.tar.zst

python-vlc:  PKGBUILDs-extra/python-vlc/*.pkg.tar.zst

python-vosk: python-srt PKGBUILDs-extra/python-vosk/*.pkg.tar.zst

python-youtube-search:  PKGBUILDs-extra/python-youtube-search/*.pkg.tar.zst

python-yt-dlp:  PKGBUILDs-extra/python-yt-dlp/*.pkg.tar.zst
