//
//  EditAlert.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import SwiftUI

struct EditAlertView: View {
    var onCancel: () -> Void
    var onConfirm: (String) -> Void
    
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 0){
            Spacer()
            
            VStack(spacing:0){
                Text("이름 수정하기")
                    .foregroundColor(Color.alertBlack)
                    .font(.pretendardMedium(size: 17))
                    .padding(.top, 19)
                    .padding(.bottom, 4)
                
                Text("해당 발표 파일의 이름을 수정할 수 있어요.")
                    .foregroundColor(Color.alertBlack)
                    .font(.pretendardMedium(size: 13))
                    .padding(.bottom, 14)
                
                TextField("협체발표", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isFocused)
                    .frame(height: 26)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 17)
                
                Divider()
                    .foregroundColor(Color.alertDivider.opacity(0.36))
                
                HStack(alignment: .top,spacing:0){
                    Button(action:{
                        isFocused = false  // 즉시 포커스 해제
                        onCancel()
                    }){
                        Text("취소")
                            .foregroundColor(Color.primary)
                            .font(.pretendardMedium(size: 17))
                            .padding(.vertical, 11)
                            .padding(.horizontal, 52)
                    }
                    
                    Divider()
                        .frame(width: 1, height: 44)
                        .foregroundColor(Color.alertDivider.opacity(0.36))
                    
                    Button(action:{
                        isFocused = false  // 즉시 포커스 해제
                        onConfirm(text)
                    }){
                        Text("확인")
                            .foregroundColor(Color.primary)
                            .font(.pretendardMedium(size: 17))
                            .padding(.vertical, 11)
                            .padding(.horizontal, 50)
                    }
                    
                } // : HStack
                
            } // : VStack
            .frame(width: 270, height: 160)
            .background(Color.alertContiner)
            .cornerRadius(14)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                }
            }
            
            Spacer()
        } // : HStack
        .frame(maxHeight: .infinity)
        .background(Color.black.opacity(0.3).ignoresSafeArea())
    }
}

#Preview {
    EditAlertView(
        onCancel: {
            print("취소됨")
        },
        onConfirm: { newText in
            print("확인됨, 입력된 값: \(newText)")
        })
}
