import SwiftUI

struct MonitorGroupListView: View {
    @EnvironmentObject var viewModel: DataOtterModel
    @Binding var monitor: MonitorStatus
    @State var groupToggles: [GroupToggle] = []
    @State var creatingGroup = false
    @State var monitorCreationText = ""
    @State var createGroupAlert = false
    @State var addToGroupAlert = false
    
    var body: some View {
        List {
            Section("Groups"){
                ForEach($groupToggles.indices, id: \.self) { index in
                    Toggle(isOn: $groupToggles[index].isSelected) {
                        Text(groupToggles[index].name)
                    }
                    .onChange(of: groupToggles[index].isSelected) { _, newValue in
                        onToggleChange(newValue: newValue, index: index)
                    }
                }
                groupCreationSection
            }
        }
        .onAppear {
            fetchGroupToggles()
        }
        .refreshable {
            viewModel.refreshData()
        }
        .alert("Group creation error", isPresented: $createGroupAlert) {
            Button("Okay", role: .cancel) {}
        }
        .alert("Group addition/removal error", isPresented: $addToGroupAlert) {
            Button("Okay", role: .cancel) {}
        }
    }
    
    var groupCreationSection: some View {
        Group {
            if creatingGroup {
                TextField("Group Name", text: $monitorCreationText)
                creationButtons
            } else {
                HStack {
                    Spacer()
                    Button("Create Group") { withAnimation { creatingGroup.toggle() } }
                    Spacer()
                }
            }
        }
    }
    
    var creationButtons: some View {
        HStack {
            Spacer()
            Button("Cancel") {
                cancelCreation()
            }
            .buttonStyle(.bordered)
            .foregroundStyle(.red)
            Spacer()
            Divider()
            Spacer()
            Button("Confirm") {
                confirmCreation()
            }
            .buttonStyle(.borderedProminent)
            .disabled(monitorCreationText.isEmpty)
            Spacer()
        }
    }
    
    private func fetchGroupToggles() {
        groupToggles = viewModel.groups.map { GroupToggle(id: $0.id, name: $0.name, isSelected: $0.monitors.contains(monitor.id)) }
    }
    
    private func onToggleChange(newValue: Bool, index: Int) {
        print("Toggle for \(groupToggles[index].name) changed to \(newValue)")
        if(addToGroupAlert){ return }
        if(newValue){
            viewModel.addMonitorToGroup(monitorId: monitor.id, groupId: groupToggles[index].id) { result in
                switch(result){
                case .failure(let error):
                    print(error)
                    addToGroupAlert = true
                    groupToggles[index].isSelected.toggle()
                case .success(_):
                    print("Success")
                }
            }
        } else {
            viewModel.removeMonitorFromGroup(monitorId: monitor.id, groupId: groupToggles[index].id) { result in
                switch(result){
                case .success(_):
                    print("Success")
                case .failure(let error):
                    print(error)
                    addToGroupAlert = true
                    groupToggles[index].isSelected.toggle()
                }
            }
        }
    }
    
    private func cancelCreation() {
        print("Cancel")
        monitorCreationText = ""
        withAnimation { creatingGroup.toggle() }
    }
    
    private func confirmCreation() {
        viewModel.createGroup(name: monitorCreationText){ result in
            switch result {
            case .success(let data):
                DispatchGroup().notify(queue: .main) {
                    creatingGroup = false
                    monitorCreationText = ""
                    groupToggles.append(GroupToggle(id: data.id, name: data.name, isSelected: true))
                    onToggleChange(newValue: true, index: groupToggles.count - 1)
                }
            case .failure(let error):
                createGroupAlert = true
                print(error)
            }
        }
    }
}

struct GroupToggle: Identifiable, Equatable {
    let id: Int
    let name: String
    var isSelected: Bool
}
