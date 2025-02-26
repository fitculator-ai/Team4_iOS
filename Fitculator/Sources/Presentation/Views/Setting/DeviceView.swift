import SwiftUI
import CoreBluetooth

struct DeviceView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        List {
            Section(header: Text("connectedDevice".localized)) {
                if bluetoothManager.connectedDevices.isEmpty {
                    Text("noDevice".localized)
                        .foregroundStyle(.gray)
                } else {
                    ForEach(bluetoothManager.connectedDevices, id: \.self) { device in
                        Text(device)
                    }
                }
            }
            .listRowBackground(Color.gray.opacity(0.2))
            
            Section {
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("gotoBluetooth".localized)
                    }
                    .foregroundColor(.blue)
                }
            }
            .listRowBackground(Color.gray.opacity(0.2))
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor.opacity(1))
        .navigationTitle("device".localized)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            bluetoothManager.startScanning()
        }
    }
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager?
    @Published var connectedDevices: [String] = []

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        connectedDevices.removeAll()
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            connectedDevices = ["enableBluetooth".localized]
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name, !connectedDevices.contains(name) {
            DispatchQueue.main.async {
                self.connectedDevices.append(name)
            }
        }
    }
}
