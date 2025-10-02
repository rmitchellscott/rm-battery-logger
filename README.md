# rm-battery-logger
[![rm2](https://img.shields.io/badge/rM2-supported-green)](https://remarkable.com/store/remarkable-2)
[![rmpp](https://img.shields.io/badge/rMPP-supported-green)](https://remarkable.com/products/remarkable-paper/pro)
[![rmppm](https://img.shields.io/badge/rMPPM-supported-green)](https://remarkable.com/products/remarkable-paper/pro-move)

Battery and frontlight monitoring for reMarkable tablets. Logs statistics to daily CSV files.

## Features

- Logs battery capacity, charge, voltage, current, temperature, and frontlight brightness
- Creates daily CSV files
- Checks every minute, logs every 5+ minutes
- Works on reMarkable 2, Paper Pro, and Paper Pro Move
- Pure bash implementation

## Automatic Installation (Recommended)

> [!CAUTION]
> Piping code from the internet directly into `bash` can be dangerous. Make sure you trust the source and know what it will do to your system.


```bash
wget -O - https://raw.githubusercontent.com/rmitchellscott/rm-battery-logger/main/install.sh | bash
```
Installs to `/home/root/rm-battery-logger`

## Manual Installation

```bash
cd /home/root
wget https://github.com/rmitchellscott/rm-battery-logger/releases/latest/download/rm-battery-logger.tar.gz
mkdir -p rm-battery-logger
tar -xzf rm-battery-logger.tar.gz -C rm-battery-logger
cd rm-battery-logger
chmod +x *.sh
./start.sh
```

## Usage

Start logging:
```bash
rm-battery-logger/start.sh
```

Stop logging:
```bash
rm-battery-logger/stop.sh
```

Check version:
```bash
rm-battery-logger/battery_logger.sh -v
```

## Log Format

Files are saved as `battery_log_YYYY-MM-DD.csv` in the installation directory.

### Columns

| Column | Unit | Description |
|--------|------|-------------|
| timestamp | ISO 8601 | Time of reading |
| capacity_percent | % | Battery level |
| charge_now_mah | mAh | Current charge |
| charge_full_mah | mAh | Full charge capacity |
| status | - | Charging/Discharging/Full |
| current_avg_ma | mA | Average current (negative = discharging) |
| voltage_v | V | Battery voltage |
| temp_c | °C | Battery temperature |
| brightness | 0-2047 | Frontlight level (0 on reMarkable 2) |

## Device Compatibility

| Device | Battery Controller | Frontlight |
|--------|--------------------|------------|
| reMarkable 2 | max77818 | No |
| reMarkable Paper Pro | max1726x | Yes |
| reMarkable Paper Pro Move | max77818 | Yes |

Auto-detects battery controller at runtime.

## Compensation to Match UI Values

The operating system reports different values from the reMarkable tablet UI.

**Paper Pro Move**
```
MIN(100, IF([capacity_percent]>=80, 1.1164*[capacity_percent]-9.363, 1.1904*[capacity_percent]-14.9555))
```

## License

MIT
