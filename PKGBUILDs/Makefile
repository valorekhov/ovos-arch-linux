.PHONY: all clean
RUN_MAKEPKG := makepkg --syncdeps --noconfirm

ovos-bus-server: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

ovos-dashboard: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

ovos-shell: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

ovos-splash: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-audio: python-ovos-bus-client python-ovos-config python-ovos-ocp-files-plugin python-ovos-ocp-m3u-plugin python-ovos-ocp-news-plugin python-ovos-ocp-rss-plugin python-ovos-plugin-manager python-ovos-tts-plugin-mimic3-server python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-audio-plugin-simple: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-backend-client: python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-backend-manager: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-bus-client: python-ovos-config python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-classifiers: python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-cli-client: python-ovos-utils python-ovos-bus-client
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-config: python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-config-assistant: python-ovos-backend-client python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-core: python-ovos-backend-client python-ovos-bus-client python-ovos-workshop python-ovos-classifiers python-ovos-config python-ovos-lingua-franca python-ovos-plugin-manager python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-gui: python-ovos-backend-client python-ovos-bus-client python-ovos-config python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-lingua-franca: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-listener: python-ovos-backend-client python-ovos-bus-client python-ovos-config python-ovos-plugin-manager python-ovos-stt-plugin-server python-ovos-stt-plugin-vosk python-ovos-utils python-ovos-vad-plugin-webrtcvad python-ovos-ww-plugin-pocketsphinx python-ovos-ww-plugin-precise-lite python-ovos-ww-plugin-vosk
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-messagebus: python-ovos-config python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-notifications-service: python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ocp-audio-plugin: python-ovos-audio-plugin-simple python-ovos-workshop python-ovos-bus-client python-ovos-ocp-files-plugin python-ovos-plugin-manager python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ocp-bandcamp-plugin: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ocp-deezer-plugin: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ocp-files-plugin: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ocp-m3u-plugin: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ocp-news-plugin: python-ovos-ocp-m3u-plugin python-ovos-ocp-rss-plugin
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ocp-rss-plugin: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ocp-youtube-plugin: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-personal-backend: python-ovos-plugin-manager python-ovos-stt-plugin-server python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal: python-ovos-workshop python-ovos-bus-client python-ovos-config python-ovos-phal-plugin-connectivity-events python-ovos-phal-plugin-ipgeo python-ovos-PHAL-plugin-network-manager python-ovos-PHAL-plugin-oauth python-ovos-PHAL-plugin-system python-ovos-plugin-manager python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-alsa: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-balena-wifi: python-ovos-utils python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-brightness-control-rpi: python-ovos-utils python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-color-scheme-manager: python-ovos-utils python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-configuration-provider: python-ovos-utils python-ovos-config python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-connectivity-events: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-dashboard: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-display-manager-ipc: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-gpsd: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-gui-network-client: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-homeassistant: python-ovos-config python-ovos-PHAL-plugin-oauth python-ovos-plugin-manager python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-ipc2bus: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-ipgeo: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-mk1: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-mk2: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-network-manager: python-ovos-utils python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-notification-widgets: python-ovos-utils python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-oauth: python-ovos-backend-client python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-respeaker-2mic: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-respeaker-4mic: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-system: python-ovos-config python-ovos-plugin-manager python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-phal-plugin-wifi-setup: python-ovos-utils python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-plugin-manager: python-ovos-bus-client python-ovos-config python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-skill-installer: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-skill-manager: python-ovos-config python-ovos-skill-installer python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-stt-http-server: python-ovos-plugin-manager python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-stt-plugin-chromium: python-ovos-utils python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-stt-plugin-pocketsphinx: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-stt-plugin-selene: python-ovos-utils python-ovos-backend-client python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-stt-plugin-server: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-stt-plugin-vosk: python-ovos-skill-installer python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-stt-plugin-whispercpp: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-tts-plugin-marytts: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-tts-plugin-mimic: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-tts-plugin-mimic2: python-ovos-plugin-manager python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-tts-plugin-mimic3-server: python-ovos-plugin-manager python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-tts-plugin-pico: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-tts-server: python-ovos-plugin-manager python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-tts-server-plugin: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-utils: 
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-vad-plugin-webrtcvad: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-vlc-plugin: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-workshop: python-ovos-backend-client python-ovos-config python-ovos-bus-client python-ovos-lingua-franca python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ww-plugin-pocketsphinx: python-ovos-plugin-manager
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ww-plugin-precise: python-ovos-plugin-manager python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ww-plugin-precise-lite: python-ovos-plugin-manager python-ovos-utils
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

python-ovos-ww-plugin-vosk: python-ovos-plugin-manager python-ovos-skill-installer
	@echo 'Building $@'
	@cd $@ && $(RUN_MAKEPKG)

all: ovos-bus-server \
	ovos-dashboard \
	ovos-shell \
	ovos-splash \
	python-ovos-audio \
	python-ovos-audio-plugin-simple \
	python-ovos-backend-client \
	python-ovos-backend-manager \
	python-ovos-bus-client \
	python-ovos-classifiers \
	python-ovos-cli-client \
	python-ovos-config \
	python-ovos-config-assistant \
	python-ovos-core \
	python-ovos-gui \
	python-ovos-lingua-franca \
	python-ovos-listener \
	python-ovos-messagebus \
	python-ovos-notifications-service \
	python-ovos-ocp-audio-plugin \
	python-ovos-ocp-bandcamp-plugin \
	python-ovos-ocp-deezer-plugin \
	python-ovos-ocp-files-plugin \
	python-ovos-ocp-m3u-plugin \
	python-ovos-ocp-news-plugin \
	python-ovos-ocp-rss-plugin \
	python-ovos-ocp-youtube-plugin \
	python-ovos-personal-backend \
	python-ovos-phal \
	python-ovos-phal-plugin-alsa \
	python-ovos-phal-plugin-balena-wifi \
	python-ovos-phal-plugin-brightness-control-rpi \
	python-ovos-phal-plugin-color-scheme-manager \
	python-ovos-phal-plugin-configuration-provider \
	python-ovos-phal-plugin-connectivity-events \
	python-ovos-phal-plugin-dashboard \
	python-ovos-phal-plugin-display-manager-ipc \
	python-ovos-phal-plugin-gpsd \
	python-ovos-phal-plugin-gui-network-client \
	python-ovos-phal-plugin-homeassistant \
	python-ovos-phal-plugin-ipc2bus \
	python-ovos-phal-plugin-ipgeo \
	python-ovos-phal-plugin-mk1 \
	python-ovos-phal-plugin-mk2 \
	python-ovos-phal-plugin-network-manager \
	python-ovos-phal-plugin-notification-widgets \
	python-ovos-phal-plugin-oauth \
	python-ovos-phal-plugin-respeaker-2mic \
	python-ovos-phal-plugin-respeaker-4mic \
	python-ovos-phal-plugin-system \
	python-ovos-phal-plugin-wifi-setup \
	python-ovos-plugin-manager \
	python-ovos-skill-installer \
	python-ovos-skill-manager \
	python-ovos-stt-http-server \
	python-ovos-stt-plugin-chromium \
	python-ovos-stt-plugin-pocketsphinx \
	python-ovos-stt-plugin-selene \
	python-ovos-stt-plugin-server \
	python-ovos-stt-plugin-vosk \
	python-ovos-stt-plugin-whispercpp \
	python-ovos-tts-plugin-marytts \
	python-ovos-tts-plugin-mimic \
	python-ovos-tts-plugin-mimic2 \
	python-ovos-tts-plugin-mimic3-server \
	python-ovos-tts-plugin-pico \
	python-ovos-tts-server \
	python-ovos-tts-server-plugin \
	python-ovos-utils \
	python-ovos-vad-plugin-webrtcvad \
	python-ovos-vlc-plugin \
	python-ovos-workshop \
	python-ovos-ww-plugin-pocketsphinx \
	python-ovos-ww-plugin-precise \
	python-ovos-ww-plugin-precise-lite \
	python-ovos-ww-plugin-vosk

clean:
	@rm -rf ./*/pkg ./*/src

