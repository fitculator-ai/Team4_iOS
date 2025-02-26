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
            bluetoothManager.checkConnectedDevices()
        }
    }
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager?
    @Published var connectedDevices: [String] = []
    private var retrievedPeripherals: [CBPeripheral] = []
    
    private let watchServicesUUIDs: [CBUUID] = [
        CBUUID(string: "180D")
    ]

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func checkConnectedDevices() {
        connectedDevices.removeAll()

        if centralManager?.state != .poweredOn {
            connectedDevices = ["enableBluetooth".localized]
            return
        }
        
        if let connectedPeripherals = centralManager?.retrieveConnectedPeripherals(withServices: watchServicesUUIDs) {
            if connectedPeripherals.isEmpty {
                connectedDevices = ["noConnectedWatch".localized]
            } else {
                retrievedPeripherals = connectedPeripherals
                for peripheral in connectedPeripherals {
                    peripheral.delegate = self
                    if let name = peripheral.name, !name.isEmpty {
                        DispatchQueue.main.async {
                            self.connectedDevices.append(name)
                        }
                    }
                }
            }
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            checkConnectedDevices()
        } else {
            connectedDevices = ["enableBluetooth".localized]
        }
    }
}
