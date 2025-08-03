import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isExpanded: Bool
    @State private var searchBarWidth: CGFloat = 0
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer() // 왼쪽 공간을 채워서 오른쪽 정렬
            
            HStack(spacing: 0) {
                TextField("연습 목록을 검색하세요", text: $searchText)
                    .font(.pretendardMedium(size: 16))
                    .padding(.vertical, 11)
                    .padding(.leading, 16)
                    .background(Color.white)
                    .cornerRadius(10)
                    .focused($isFocused)
                
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isExpanded = false
                        searchText = ""
                    }
                    isFocused = false
                }) {
                    Image("search_cancel")
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                }
            }
            .background(Color.white)
            .cornerRadius(20)
            .applyShadowStyle()
            .frame(width: searchBarWidth)
            .clipped()
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: searchBarWidth)
        }
        .padding(.bottom, 20)
        .onAppear {
            searchBarWidth = 0
            withAnimation {
                searchBarWidth = UIScreen.main.bounds.width - 32
            }
            if isExpanded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isFocused = true
                }
            }
        }
        .onChange(of: isExpanded) { newValue in
            if !newValue {
                withAnimation {
                    searchBarWidth = 0
                }
                isFocused = false
            }
        }
    }
}

#Preview {
    SearchBarView(searchText: .constant(""), isExpanded: .constant(true))
}
