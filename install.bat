if exist %LOCALAPPDATA%\I2P\i2ptunnel.config.d\ (
  xcopy /s /i /y Nextcloud-HTTP-Proxy.config %LOCALAPPDATA%\I2P\i2ptunnel.config.d/Nextcloud-HTTP-Proxy.config
) else (
  echo No
)

if exist %APPDATA%\I2P\i2ptunnel.config.d\ (
  xcopy /s /i /y Nextcloud-HTTP-Proxy.config %APPDATA%\I2P\i2ptunnel.config.d/Nextcloud-HTTP-Proxy.config
) else (
  echo No
)

findstr /c:7671 %APPDATA%\Nextcloud\nextcloud.cfg
if not %errorlevel% == 0 (
  xcopy /s /i /y nextcloud.cfg %APPDATA%\Nextcloud\nextcloud.cfg
)