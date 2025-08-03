//
//  DeleteAlertView.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import SwiftUI

struct DeleteAlertView: View {
    var onCancel: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing:0){
            Spacer()
            
            VStack(spacing:0){
                Text("발표 파일 삭제하기")
                    .foregroundColor(Color.alertBlack)
                    .font(.pretendardSemiBold(size: 17))
                    .padding(.top, 16)
                    .padding(.bottom, 2)
                
                Text("발표 파일을 삭제하시겠어요?")
                    .foregroundColor(Color.alertBlack)
                    .font(.pretendardRegular(size: 13))
                
                Text("이 작업은 되돌릴 수 없어요.")
                    .foregroundColor(Color.alertBlack)
                    .font(.pretendardRegular(size: 13))
                    .padding(.bottom, 16)
                
                Divider()
                    .foregroundColor(Color.alertDivider.opacity(0.36))
                
                HStack(alignment: .top, spacing:0){
                    Spacer()
                    
                    Button(action:{
                        onCancel()
                    }){
                        Text("취소")
                            .foregroundColor(Color.primary)
                            .font(.pretendardMedium(size: 17))
                            .padding(.vertical, 11)
                            .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                    
                    Divider()
                        .frame(width: 1, height: 44)
                        .foregroundColor(Color.alertDivider.opacity(0.36))
                    
                    Button(action:{
                        onDelete()
                    }){
                        Text("삭제하기")
                            .foregroundColor(Color.preeRed)
                            .font(.pretendardSemiBold(size: 17))
                            .padding(.vertical, 11)
                            .padding(.horizontal, 40)
                    }
                    
                } // : HStack
                
            }// : VStack
            .frame(width: 273, height: 136)
            .background(Color.alertContiner)
            .cornerRadius(14)
            
            Spacer()
        } //: HStack
        .frame(maxHeight: .infinity)
        .background(Color.black.opacity(0.3).ignoresSafeArea())
    }
}

#Preview {
    DeleteAlertView(
        onCancel: {
            print("취소됨")
        },
        onDelete: {
            print("삭제됨")
        },
    )
}
