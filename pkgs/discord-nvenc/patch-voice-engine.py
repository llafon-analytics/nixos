import sys
from pathlib import Path

voice_index = Path(sys.argv[1])
text = voice_index.read_text()

def replace_once(old, new):
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"Expected exactly one match, found {count}: {old[:120]!r}")
    text = text.replace(old, new, 1)

replace_once(
    "        setTransportOptions: (options) => instance.setTransportOptions(options),",
    """        setTransportOptions: (options) => {
          let patchedOptions = options;
          if (process.platform === 'linux'
              && options != null
              && typeof options === 'object'
              && typeof options.videoEncoderExperiments === 'string') {
              const values = [];
              const seen = new Set();
              for (const part of options.videoEncoderExperiments.split(',')) {
                  const token = part.trim();
                  if (!token || token === 'vaapi' || seen.has(token)) {
                      continue;
                  }
                  values.push(token);
                  seen.add(token);
              }
              for (const token of ['linux-nvenc', 'useCaptureDeviceForEncode']) {
                  if (seen.has(token)) {
                      continue;
                  }
                  values.push(token);
                  seen.add(token);
              }
              const nextVideoEncoderExperiments = values.join(',');
              if (nextVideoEncoderExperiments !== options.videoEncoderExperiments) {
                  patchedOptions = {
                      ...options,
                      videoEncoderExperiments: nextVideoEncoderExperiments,
                  };
              }
          }
          return instance.setTransportOptions(patchedOptions);
      },""",
)

replace_once(
    "        setDesktopSourceWithOptions: (options) => instance.setDesktopSourceWithOptions(options),",
    """        setDesktopSourceWithOptions: (options) => {
          let patchedOptions = options;
          if (process.platform === 'linux'
              && options != null
              && typeof options === 'object'
              && options.useCaptureDeviceForEncode !== true) {
              patchedOptions = {
                  ...options,
                  useCaptureDeviceForEncode: true,
              };
          }
          return instance.setDesktopSourceWithOptions(patchedOptions);
      },""",
)

replace_once(
    """VoiceEngine.createVoiceConnectionWithOptions = function (userId, connectionOptions, onConnectCallback) {
    const instance = new VoiceEngine.VoiceConnection(userId, connectionOptions, onConnectCallback);
    return bindConnectionInstance(instance);
};""",
    """VoiceEngine.createVoiceConnectionWithOptions = function (userId, connectionOptions, onConnectCallback) {
    let patchedConnectionOptions = connectionOptions;
    if (process.platform === 'linux' && connectionOptions != null && typeof connectionOptions === 'object') {
        const experiments = Array.isArray(connectionOptions.experiments) ? [...connectionOptions.experiments] : [];
        if (!experiments.includes('linux-vulkan')) {
            experiments.push('linux-vulkan');
            patchedConnectionOptions = {
                ...connectionOptions,
                experiments,
            };
        }
    }
    const instance = new VoiceEngine.VoiceConnection(userId, patchedConnectionOptions, onConnectCallback);
    return bindConnectionInstance(instance);
};""",
)

voice_index.write_text(text)
