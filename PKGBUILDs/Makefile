.PHONY: all clean
RUN_MAKEPKG := makepkg --syncdeps --noconfirm --force --install
PACKAGES := ovos-bus-server \
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

# ovos-bus-server
ovos-bus-server:  ovos-bus-server-%.pkg.tar.zst
ovos-bus-server-%.pkg.tar.zst:
	@echo 'Building ovos-bus-server'
	@cd 'ovos-bus-server' && $(RUN_MAKEPKG)

# ovos-dashboard
ovos-dashboard:  ovos-dashboard-%.pkg.tar.zst
ovos-dashboard-%.pkg.tar.zst:
	@echo 'Building ovos-dashboard'
	@cd 'ovos-dashboard' && $(RUN_MAKEPKG)

# ovos-shell
ovos-shell:  ovos-shell-%.pkg.tar.zst
ovos-shell-%.pkg.tar.zst:
	@echo 'Building ovos-shell'
	@cd 'ovos-shell' && $(RUN_MAKEPKG)

# ovos-splash
ovos-splash:  ovos-splash-%.pkg.tar.zst
ovos-splash-%.pkg.tar.zst:
	@echo 'Building ovos-splash'
	@cd 'ovos-splash' && $(RUN_MAKEPKG)

# python-ovos-audio
python-ovos-audio: python-ovos-bus-client python-ovos-config python-ovos-ocp-files-plugin python-ovos-ocp-m3u-plugin python-ovos-ocp-news-plugin python-ovos-ocp-rss-plugin python-ovos-plugin-manager python-ovos-tts-plugin-mimic3-server python-ovos-utils python-ovos-audio-%.pkg.tar.zst
python-ovos-audio-%.pkg.tar.zst:
	@echo 'Building python-ovos-audio'
	@cd 'python-ovos-audio' && $(RUN_MAKEPKG)

# python-ovos-audio-plugin-simple
python-ovos-audio-plugin-simple: python-ovos-plugin-manager python-ovos-audio-plugin-simple-%.pkg.tar.zst
python-ovos-audio-plugin-simple-%.pkg.tar.zst:
	@echo 'Building python-ovos-audio-plugin-simple'
	@cd 'python-ovos-audio-plugin-simple' && $(RUN_MAKEPKG)

# python-ovos-backend-client
python-ovos-backend-client: python-ovos-utils python-ovos-backend-client-%.pkg.tar.zst
python-ovos-backend-client-%.pkg.tar.zst:
	@echo 'Building python-ovos-backend-client'
	@cd 'python-ovos-backend-client' && $(RUN_MAKEPKG)

# python-ovos-backend-manager
python-ovos-backend-manager:  python-ovos-backend-manager-%.pkg.tar.zst
python-ovos-backend-manager-%.pkg.tar.zst:
	@echo 'Building python-ovos-backend-manager'
	@cd 'python-ovos-backend-manager' && $(RUN_MAKEPKG)

# python-ovos-bus-client
python-ovos-bus-client: python-ovos-config python-ovos-utils python-ovos-bus-client-%.pkg.tar.zst
python-ovos-bus-client-%.pkg.tar.zst:
	@echo 'Building python-ovos-bus-client'
	@cd 'python-ovos-bus-client' && $(RUN_MAKEPKG)

# python-ovos-classifiers
python-ovos-classifiers: python-ovos-utils python-ovos-classifiers-%.pkg.tar.zst
python-ovos-classifiers-%.pkg.tar.zst:
	@echo 'Building python-ovos-classifiers'
	@cd 'python-ovos-classifiers' && $(RUN_MAKEPKG)

# python-ovos-cli-client
python-ovos-cli-client: python-ovos-utils python-ovos-bus-client python-ovos-cli-client-%.pkg.tar.zst
python-ovos-cli-client-%.pkg.tar.zst:
	@echo 'Building python-ovos-cli-client'
	@cd 'python-ovos-cli-client' && $(RUN_MAKEPKG)

# python-ovos-config
python-ovos-config: python-ovos-utils python-ovos-config-%.pkg.tar.zst
python-ovos-config-%.pkg.tar.zst:
	@echo 'Building python-ovos-config'
	@cd 'python-ovos-config' && $(RUN_MAKEPKG)

# python-ovos-config-assistant
python-ovos-config-assistant: python-ovos-backend-client python-ovos-utils python-ovos-config-assistant-%.pkg.tar.zst
python-ovos-config-assistant-%.pkg.tar.zst:
	@echo 'Building python-ovos-config-assistant'
	@cd 'python-ovos-config-assistant' && $(RUN_MAKEPKG)

# python-ovos-core
python-ovos-core: python-ovos-backend-client python-ovos-bus-client python-ovos-workshop python-ovos-classifiers python-ovos-config python-ovos-lingua-franca python-ovos-plugin-manager python-ovos-utils python-ovos-core-%.pkg.tar.zst
python-ovos-core-%.pkg.tar.zst:
	@echo 'Building python-ovos-core'
	@cd 'python-ovos-core' && $(RUN_MAKEPKG)

# python-ovos-gui
python-ovos-gui: python-ovos-backend-client python-ovos-bus-client python-ovos-config python-ovos-utils python-ovos-gui-%.pkg.tar.zst
python-ovos-gui-%.pkg.tar.zst:
	@echo 'Building python-ovos-gui'
	@cd 'python-ovos-gui' && $(RUN_MAKEPKG)

# python-ovos-lingua-franca
python-ovos-lingua-franca:  python-ovos-lingua-franca-%.pkg.tar.zst
python-ovos-lingua-franca-%.pkg.tar.zst:
	@echo 'Building python-ovos-lingua-franca'
	@cd 'python-ovos-lingua-franca' && $(RUN_MAKEPKG)

# python-ovos-listener
python-ovos-listener: python-ovos-backend-client python-ovos-bus-client python-ovos-config python-ovos-plugin-manager python-ovos-stt-plugin-server python-ovos-stt-plugin-vosk python-ovos-utils python-ovos-vad-plugin-webrtcvad python-ovos-ww-plugin-pocketsphinx python-ovos-ww-plugin-precise-lite python-ovos-ww-plugin-vosk python-ovos-listener-%.pkg.tar.zst
python-ovos-listener-%.pkg.tar.zst:
	@echo 'Building python-ovos-listener'
	@cd 'python-ovos-listener' && $(RUN_MAKEPKG)

# python-ovos-messagebus
python-ovos-messagebus: python-ovos-config python-ovos-utils python-ovos-messagebus-%.pkg.tar.zst
python-ovos-messagebus-%.pkg.tar.zst:
	@echo 'Building python-ovos-messagebus'
	@cd 'python-ovos-messagebus' && $(RUN_MAKEPKG)

# python-ovos-notifications-service
python-ovos-notifications-service: python-ovos-utils python-ovos-notifications-service-%.pkg.tar.zst
python-ovos-notifications-service-%.pkg.tar.zst:
	@echo 'Building python-ovos-notifications-service'
	@cd 'python-ovos-notifications-service' && $(RUN_MAKEPKG)

# python-ovos-ocp-audio-plugin
python-ovos-ocp-audio-plugin: python-ovos-audio-plugin-simple python-ovos-workshop python-ovos-bus-client python-ovos-ocp-files-plugin python-ovos-plugin-manager python-ovos-utils python-ovos-ocp-audio-plugin-%.pkg.tar.zst
python-ovos-ocp-audio-plugin-%.pkg.tar.zst:
	@echo 'Building python-ovos-ocp-audio-plugin'
	@cd 'python-ovos-ocp-audio-plugin' && $(RUN_MAKEPKG)

# python-ovos-ocp-bandcamp-plugin
python-ovos-ocp-bandcamp-plugin:  python-ovos-ocp-bandcamp-plugin-%.pkg.tar.zst
python-ovos-ocp-bandcamp-plugin-%.pkg.tar.zst:
	@echo 'Building python-ovos-ocp-bandcamp-plugin'
	@cd 'python-ovos-ocp-bandcamp-plugin' && $(RUN_MAKEPKG)

# python-ovos-ocp-deezer-plugin
python-ovos-ocp-deezer-plugin:  python-ovos-ocp-deezer-plugin-%.pkg.tar.zst
python-ovos-ocp-deezer-plugin-%.pkg.tar.zst:
	@echo 'Building python-ovos-ocp-deezer-plugin'
	@cd 'python-ovos-ocp-deezer-plugin' && $(RUN_MAKEPKG)

# python-ovos-ocp-files-plugin
python-ovos-ocp-files-plugin:  python-ovos-ocp-files-plugin-%.pkg.tar.zst
python-ovos-ocp-files-plugin-%.pkg.tar.zst:
	@echo 'Building python-ovos-ocp-files-plugin'
	@cd 'python-ovos-ocp-files-plugin' && $(RUN_MAKEPKG)

# python-ovos-ocp-m3u-plugin
python-ovos-ocp-m3u-plugin:  python-ovos-ocp-m3u-plugin-%.pkg.tar.zst
python-ovos-ocp-m3u-plugin-%.pkg.tar.zst:
	@echo 'Building python-ovos-ocp-m3u-plugin'
	@cd 'python-ovos-ocp-m3u-plugin' && $(RUN_MAKEPKG)

# python-ovos-ocp-news-plugin
python-ovos-ocp-news-plugin: python-ovos-ocp-m3u-plugin python-ovos-ocp-rss-plugin python-ovos-ocp-news-plugin-%.pkg.tar.zst
python-ovos-ocp-news-plugin-%.pkg.tar.zst:
	@echo 'Building python-ovos-ocp-news-plugin'
	@cd 'python-ovos-ocp-news-plugin' && $(RUN_MAKEPKG)

# python-ovos-ocp-rss-plugin
python-ovos-ocp-rss-plugin:  python-ovos-ocp-rss-plugin-%.pkg.tar.zst
python-ovos-ocp-rss-plugin-%.pkg.tar.zst:
	@echo 'Building python-ovos-ocp-rss-plugin'
	@cd 'python-ovos-ocp-rss-plugin' && $(RUN_MAKEPKG)

# python-ovos-ocp-youtube-plugin
python-ovos-ocp-youtube-plugin:  python-ovos-ocp-youtube-plugin-%.pkg.tar.zst
python-ovos-ocp-youtube-plugin-%.pkg.tar.zst:
	@echo 'Building python-ovos-ocp-youtube-plugin'
	@cd 'python-ovos-ocp-youtube-plugin' && $(RUN_MAKEPKG)

# python-ovos-personal-backend
python-ovos-personal-backend: python-ovos-plugin-manager python-ovos-stt-plugin-server python-ovos-utils python-ovos-personal-backend-%.pkg.tar.zst
python-ovos-personal-backend-%.pkg.tar.zst:
	@echo 'Building python-ovos-personal-backend'
	@cd 'python-ovos-personal-backend' && $(RUN_MAKEPKG)

# python-ovos-phal
python-ovos-phal: python-ovos-workshop python-ovos-bus-client python-ovos-config python-ovos-phal-plugin-connectivity-events python-ovos-phal-plugin-ipgeo python-ovos-phal-plugin-network-manager python-ovos-phal-plugin-oauth python-ovos-phal-plugin-system python-ovos-plugin-manager python-ovos-utils python-ovos-phal-%.pkg.tar.zst
python-ovos-phal-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal'
	@cd 'python-ovos-phal' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-alsa
python-ovos-phal-plugin-alsa: python-ovos-plugin-manager python-ovos-phal-plugin-alsa-%.pkg.tar.zst
python-ovos-phal-plugin-alsa-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-alsa'
	@cd 'python-ovos-phal-plugin-alsa' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-balena-wifi
python-ovos-phal-plugin-balena-wifi: python-ovos-utils python-ovos-plugin-manager python-ovos-phal-plugin-balena-wifi-%.pkg.tar.zst
python-ovos-phal-plugin-balena-wifi-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-balena-wifi'
	@cd 'python-ovos-phal-plugin-balena-wifi' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-brightness-control-rpi
python-ovos-phal-plugin-brightness-control-rpi: python-ovos-utils python-ovos-plugin-manager python-ovos-phal-plugin-brightness-control-rpi-%.pkg.tar.zst
python-ovos-phal-plugin-brightness-control-rpi-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-brightness-control-rpi'
	@cd 'python-ovos-phal-plugin-brightness-control-rpi' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-color-scheme-manager
python-ovos-phal-plugin-color-scheme-manager: python-ovos-utils python-ovos-plugin-manager python-ovos-phal-plugin-color-scheme-manager-%.pkg.tar.zst
python-ovos-phal-plugin-color-scheme-manager-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-color-scheme-manager'
	@cd 'python-ovos-phal-plugin-color-scheme-manager' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-configuration-provider
python-ovos-phal-plugin-configuration-provider: python-ovos-utils python-ovos-config python-ovos-plugin-manager python-ovos-phal-plugin-configuration-provider-%.pkg.tar.zst
python-ovos-phal-plugin-configuration-provider-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-configuration-provider'
	@cd 'python-ovos-phal-plugin-configuration-provider' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-connectivity-events
python-ovos-phal-plugin-connectivity-events: python-ovos-plugin-manager python-ovos-phal-plugin-connectivity-events-%.pkg.tar.zst
python-ovos-phal-plugin-connectivity-events-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-connectivity-events'
	@cd 'python-ovos-phal-plugin-connectivity-events' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-dashboard
python-ovos-phal-plugin-dashboard: python-ovos-plugin-manager python-ovos-phal-plugin-dashboard-%.pkg.tar.zst
python-ovos-phal-plugin-dashboard-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-dashboard'
	@cd 'python-ovos-phal-plugin-dashboard' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-display-manager-ipc
python-ovos-phal-plugin-display-manager-ipc:  python-ovos-phal-plugin-display-manager-ipc-%.pkg.tar.zst
python-ovos-phal-plugin-display-manager-ipc-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-display-manager-ipc'
	@cd 'python-ovos-phal-plugin-display-manager-ipc' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-gpsd
python-ovos-phal-plugin-gpsd:  python-ovos-phal-plugin-gpsd-%.pkg.tar.zst
python-ovos-phal-plugin-gpsd-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-gpsd'
	@cd 'python-ovos-phal-plugin-gpsd' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-gui-network-client
python-ovos-phal-plugin-gui-network-client: python-ovos-plugin-manager python-ovos-phal-plugin-gui-network-client-%.pkg.tar.zst
python-ovos-phal-plugin-gui-network-client-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-gui-network-client'
	@cd 'python-ovos-phal-plugin-gui-network-client' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-homeassistant
python-ovos-phal-plugin-homeassistant: python-ovos-config python-ovos-phal-plugin-oauth python-ovos-plugin-manager python-ovos-utils python-ovos-phal-plugin-homeassistant-%.pkg.tar.zst
python-ovos-phal-plugin-homeassistant-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-homeassistant'
	@cd 'python-ovos-phal-plugin-homeassistant' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-ipgeo
python-ovos-phal-plugin-ipgeo: python-ovos-plugin-manager python-ovos-phal-plugin-ipgeo-%.pkg.tar.zst
python-ovos-phal-plugin-ipgeo-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-ipgeo'
	@cd 'python-ovos-phal-plugin-ipgeo' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-mk1
python-ovos-phal-plugin-mk1:  python-ovos-phal-plugin-mk1-%.pkg.tar.zst
python-ovos-phal-plugin-mk1-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-mk1'
	@cd 'python-ovos-phal-plugin-mk1' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-mk2
python-ovos-phal-plugin-mk2: python-ovos-plugin-manager python-ovos-phal-plugin-mk2-%.pkg.tar.zst
python-ovos-phal-plugin-mk2-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-mk2'
	@cd 'python-ovos-phal-plugin-mk2' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-network-manager
python-ovos-phal-plugin-network-manager: python-ovos-utils python-ovos-plugin-manager python-ovos-phal-plugin-network-manager-%.pkg.tar.zst
python-ovos-phal-plugin-network-manager-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-network-manager'
	@cd 'python-ovos-phal-plugin-network-manager' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-notification-widgets
python-ovos-phal-plugin-notification-widgets: python-ovos-utils python-ovos-plugin-manager python-ovos-phal-plugin-notification-widgets-%.pkg.tar.zst
python-ovos-phal-plugin-notification-widgets-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-notification-widgets'
	@cd 'python-ovos-phal-plugin-notification-widgets' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-oauth
python-ovos-phal-plugin-oauth: python-ovos-backend-client python-ovos-utils python-ovos-phal-plugin-oauth-%.pkg.tar.zst
python-ovos-phal-plugin-oauth-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-oauth'
	@cd 'python-ovos-phal-plugin-oauth' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-respeaker-2mic
python-ovos-phal-plugin-respeaker-2mic:  python-ovos-phal-plugin-respeaker-2mic-%.pkg.tar.zst
python-ovos-phal-plugin-respeaker-2mic-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-respeaker-2mic'
	@cd 'python-ovos-phal-plugin-respeaker-2mic' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-respeaker-4mic
python-ovos-phal-plugin-respeaker-4mic:  python-ovos-phal-plugin-respeaker-4mic-%.pkg.tar.zst
python-ovos-phal-plugin-respeaker-4mic-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-respeaker-4mic'
	@cd 'python-ovos-phal-plugin-respeaker-4mic' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-system
python-ovos-phal-plugin-system: python-ovos-config python-ovos-plugin-manager python-ovos-utils python-ovos-phal-plugin-system-%.pkg.tar.zst
python-ovos-phal-plugin-system-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-system'
	@cd 'python-ovos-phal-plugin-system' && $(RUN_MAKEPKG)

# python-ovos-phal-plugin-wifi-setup
python-ovos-phal-plugin-wifi-setup: python-ovos-utils python-ovos-plugin-manager python-ovos-phal-plugin-wifi-setup-%.pkg.tar.zst
python-ovos-phal-plugin-wifi-setup-%.pkg.tar.zst:
	@echo 'Building python-ovos-phal-plugin-wifi-setup'
	@cd 'python-ovos-phal-plugin-wifi-setup' && $(RUN_MAKEPKG)

# python-ovos-plugin-manager
python-ovos-plugin-manager: python-ovos-bus-client python-ovos-config python-ovos-utils python-ovos-plugin-manager-%.pkg.tar.zst
python-ovos-plugin-manager-%.pkg.tar.zst:
	@echo 'Building python-ovos-plugin-manager'
	@cd 'python-ovos-plugin-manager' && $(RUN_MAKEPKG)

# python-ovos-skill-installer
python-ovos-skill-installer:  python-ovos-skill-installer-%.pkg.tar.zst
python-ovos-skill-installer-%.pkg.tar.zst:
	@echo 'Building python-ovos-skill-installer'
	@cd 'python-ovos-skill-installer' && $(RUN_MAKEPKG)

# python-ovos-skill-manager
python-ovos-skill-manager: python-ovos-config python-ovos-skill-installer python-ovos-utils python-ovos-skill-manager-%.pkg.tar.zst
python-ovos-skill-manager-%.pkg.tar.zst:
	@echo 'Building python-ovos-skill-manager'
	@cd 'python-ovos-skill-manager' && $(RUN_MAKEPKG)

# python-ovos-stt-http-server
python-ovos-stt-http-server: python-ovos-plugin-manager python-ovos-utils python-ovos-stt-http-server-%.pkg.tar.zst
python-ovos-stt-http-server-%.pkg.tar.zst:
	@echo 'Building python-ovos-stt-http-server'
	@cd 'python-ovos-stt-http-server' && $(RUN_MAKEPKG)

# python-ovos-stt-plugin-chromium
python-ovos-stt-plugin-chromium: python-ovos-utils python-ovos-plugin-manager python-ovos-stt-plugin-chromium-%.pkg.tar.zst
python-ovos-stt-plugin-chromium-%.pkg.tar.zst:
	@echo 'Building python-ovos-stt-plugin-chromium'
	@cd 'python-ovos-stt-plugin-chromium' && $(RUN_MAKEPKG)

# python-ovos-stt-plugin-pocketsphinx
python-ovos-stt-plugin-pocketsphinx: python-ovos-plugin-manager python-ovos-stt-plugin-pocketsphinx-%.pkg.tar.zst
python-ovos-stt-plugin-pocketsphinx-%.pkg.tar.zst:
	@echo 'Building python-ovos-stt-plugin-pocketsphinx'
	@cd 'python-ovos-stt-plugin-pocketsphinx' && $(RUN_MAKEPKG)

# python-ovos-stt-plugin-selene
python-ovos-stt-plugin-selene: python-ovos-utils python-ovos-backend-client python-ovos-plugin-manager python-ovos-stt-plugin-selene-%.pkg.tar.zst
python-ovos-stt-plugin-selene-%.pkg.tar.zst:
	@echo 'Building python-ovos-stt-plugin-selene'
	@cd 'python-ovos-stt-plugin-selene' && $(RUN_MAKEPKG)

# python-ovos-stt-plugin-server
python-ovos-stt-plugin-server: python-ovos-plugin-manager python-ovos-stt-plugin-server-%.pkg.tar.zst
python-ovos-stt-plugin-server-%.pkg.tar.zst:
	@echo 'Building python-ovos-stt-plugin-server'
	@cd 'python-ovos-stt-plugin-server' && $(RUN_MAKEPKG)

# python-ovos-stt-plugin-vosk
python-ovos-stt-plugin-vosk: python-ovos-skill-installer python-ovos-plugin-manager python-ovos-stt-plugin-vosk-%.pkg.tar.zst
python-ovos-stt-plugin-vosk-%.pkg.tar.zst:
	@echo 'Building python-ovos-stt-plugin-vosk'
	@cd 'python-ovos-stt-plugin-vosk' && $(RUN_MAKEPKG)

# python-ovos-stt-plugin-whispercpp
python-ovos-stt-plugin-whispercpp: python-ovos-plugin-manager python-ovos-stt-plugin-whispercpp-%.pkg.tar.zst
python-ovos-stt-plugin-whispercpp-%.pkg.tar.zst:
	@echo 'Building python-ovos-stt-plugin-whispercpp'
	@cd 'python-ovos-stt-plugin-whispercpp' && $(RUN_MAKEPKG)

# python-ovos-tts-plugin-marytts
python-ovos-tts-plugin-marytts:  python-ovos-tts-plugin-marytts-%.pkg.tar.zst
python-ovos-tts-plugin-marytts-%.pkg.tar.zst:
	@echo 'Building python-ovos-tts-plugin-marytts'
	@cd 'python-ovos-tts-plugin-marytts' && $(RUN_MAKEPKG)

# python-ovos-tts-plugin-mimic
python-ovos-tts-plugin-mimic: python-ovos-plugin-manager python-ovos-tts-plugin-mimic-%.pkg.tar.zst
python-ovos-tts-plugin-mimic-%.pkg.tar.zst:
	@echo 'Building python-ovos-tts-plugin-mimic'
	@cd 'python-ovos-tts-plugin-mimic' && $(RUN_MAKEPKG)

# python-ovos-tts-plugin-mimic2
python-ovos-tts-plugin-mimic2: python-ovos-plugin-manager python-ovos-utils python-ovos-tts-plugin-mimic2-%.pkg.tar.zst
python-ovos-tts-plugin-mimic2-%.pkg.tar.zst:
	@echo 'Building python-ovos-tts-plugin-mimic2'
	@cd 'python-ovos-tts-plugin-mimic2' && $(RUN_MAKEPKG)

# python-ovos-tts-plugin-mimic3-server
python-ovos-tts-plugin-mimic3-server: python-ovos-plugin-manager python-ovos-utils python-ovos-tts-plugin-mimic3-server-%.pkg.tar.zst
python-ovos-tts-plugin-mimic3-server-%.pkg.tar.zst:
	@echo 'Building python-ovos-tts-plugin-mimic3-server'
	@cd 'python-ovos-tts-plugin-mimic3-server' && $(RUN_MAKEPKG)

# python-ovos-tts-plugin-pico
python-ovos-tts-plugin-pico: python-ovos-plugin-manager python-ovos-tts-plugin-pico-%.pkg.tar.zst
python-ovos-tts-plugin-pico-%.pkg.tar.zst:
	@echo 'Building python-ovos-tts-plugin-pico'
	@cd 'python-ovos-tts-plugin-pico' && $(RUN_MAKEPKG)

# python-ovos-tts-server
python-ovos-tts-server: python-ovos-plugin-manager python-ovos-utils python-ovos-tts-server-%.pkg.tar.zst
python-ovos-tts-server-%.pkg.tar.zst:
	@echo 'Building python-ovos-tts-server'
	@cd 'python-ovos-tts-server' && $(RUN_MAKEPKG)

# python-ovos-tts-server-plugin
python-ovos-tts-server-plugin: python-ovos-plugin-manager python-ovos-tts-server-plugin-%.pkg.tar.zst
python-ovos-tts-server-plugin-%.pkg.tar.zst:
	@echo 'Building python-ovos-tts-server-plugin'
	@cd 'python-ovos-tts-server-plugin' && $(RUN_MAKEPKG)

# python-ovos-utils
python-ovos-utils:  python-ovos-utils-%.pkg.tar.zst
python-ovos-utils-%.pkg.tar.zst:
	@echo 'Building python-ovos-utils'
	@cd 'python-ovos-utils' && $(RUN_MAKEPKG)

# python-ovos-vad-plugin-webrtcvad
python-ovos-vad-plugin-webrtcvad: python-ovos-plugin-manager python-ovos-vad-plugin-webrtcvad-%.pkg.tar.zst
python-ovos-vad-plugin-webrtcvad-%.pkg.tar.zst:
	@echo 'Building python-ovos-vad-plugin-webrtcvad'
	@cd 'python-ovos-vad-plugin-webrtcvad' && $(RUN_MAKEPKG)

# python-ovos-vlc-plugin
python-ovos-vlc-plugin: python-ovos-plugin-manager python-ovos-vlc-plugin-%.pkg.tar.zst
python-ovos-vlc-plugin-%.pkg.tar.zst:
	@echo 'Building python-ovos-vlc-plugin'
	@cd 'python-ovos-vlc-plugin' && $(RUN_MAKEPKG)

# python-ovos-workshop
python-ovos-workshop: python-ovos-backend-client python-ovos-config python-ovos-bus-client python-ovos-lingua-franca python-ovos-utils python-ovos-workshop-%.pkg.tar.zst
python-ovos-workshop-%.pkg.tar.zst:
	@echo 'Building python-ovos-workshop'
	@cd 'python-ovos-workshop' && $(RUN_MAKEPKG)

# python-ovos-ww-plugin-pocketsphinx
python-ovos-ww-plugin-pocketsphinx: python-ovos-plugin-manager python-ovos-ww-plugin-pocketsphinx-%.pkg.tar.zst
python-ovos-ww-plugin-pocketsphinx-%.pkg.tar.zst:
	@echo 'Building python-ovos-ww-plugin-pocketsphinx'
	@cd 'python-ovos-ww-plugin-pocketsphinx' && $(RUN_MAKEPKG)

# python-ovos-ww-plugin-precise
python-ovos-ww-plugin-precise: python-ovos-plugin-manager python-ovos-utils python-ovos-ww-plugin-precise-%.pkg.tar.zst
python-ovos-ww-plugin-precise-%.pkg.tar.zst:
	@echo 'Building python-ovos-ww-plugin-precise'
	@cd 'python-ovos-ww-plugin-precise' && $(RUN_MAKEPKG)

# python-ovos-ww-plugin-precise-lite
python-ovos-ww-plugin-precise-lite: python-ovos-plugin-manager python-ovos-utils python-ovos-ww-plugin-precise-lite-%.pkg.tar.zst
python-ovos-ww-plugin-precise-lite-%.pkg.tar.zst:
	@echo 'Building python-ovos-ww-plugin-precise-lite'
	@cd 'python-ovos-ww-plugin-precise-lite' && $(RUN_MAKEPKG)

# python-ovos-ww-plugin-vosk
python-ovos-ww-plugin-vosk: python-ovos-plugin-manager python-ovos-skill-installer python-ovos-ww-plugin-vosk-%.pkg.tar.zst
python-ovos-ww-plugin-vosk-%.pkg.tar.zst:
	@echo 'Building python-ovos-ww-plugin-vosk'
	@cd 'python-ovos-ww-plugin-vosk' && $(RUN_MAKEPKG)

all: $(PACKAGES)

clean:
	@rm -rf ./*/pkg ./*/src ./*/src/*.pkg.tar*

uninstall:
	@pacman -Qq | sort | comm -12 - <(echo "$(PACKAGES)" | tr ' ' '\n' | sort) | xargs sudo pacman -Rcns --noconfirm
