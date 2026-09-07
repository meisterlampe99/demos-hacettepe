# Setup

## 1. Install Apio

Apio includes the OSS-CAD-Suite and OpenXC7, with many board database files pre-generated.

```bash
pip install apio
```

> If pip installs are locked, create a virtual environment first.

```bash
cd ~
mkdir apio
python3 -m venv ~/apio
source ~/apio/bin/activate
pip install apio
```

#### Install all dependencies

list all supported boards to trigger the download of all required tools and files.
```bash
apio boards
```

the virtual environment is not needed for tool calling, so it can be left with:

```bash
deactivate
```

## 2. Add a udev rule for the target board

```bash
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0403", MODE="0666"' | sudo tee /etc/udev/rules.d/99-ftdi.rules

sudo udevadm control --reload-rules && sudo udevadm trigger
```

---

## WSL2 Setup for BASYS3 Boards

> Uploading the bitstream is faster in WSL2.

### Handover an FPGA board to WLS2
Additional steps to share a physically connected board with WSL2

#### 1. Install usbipd-win on Windows

```powershell
winget install usbipd
```

#### 2. Install USB/IP tools in WSL

```bash
sudo apt install linux-tools-generic hwdata
sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/*-generic/usbip 20
```

#### 3. List available USB devices 

```powershell
usbipd list
```

Example output:

```text
BUSID  VID:PID    DEVICE                  STATE
2-1    1234:5678  My USB Device           Not shared
```

#### 4. Bind (share) the device — one time only

```powershell
usbipd bind --busid 2-1
```

#### 5. Attach the device to WSL

```powershell
usbipd attach --wsl --busid 2-1
```

#### 6. Verify in WSL

```bash
lsusb
```
