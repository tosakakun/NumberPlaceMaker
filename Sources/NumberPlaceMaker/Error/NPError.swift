//
//  NPError.swift
//  NumberPlaceMaker
//
//  Created by tosakakun on 2022/06/09.
//

import Foundation

public enum NPError: Error {
    /// row 行 : column 列 の数字を決められなかった
    case cannotDetermineSquareNumber(row: Int, column: Int)
    /// row 行の数字を決められなかった
    case cannotDetermineRowNumber(row: Int)
    /// Board を準備できなかった
    case cannotProvideBoard
    /// 必要な穴を増やすことができなかった
    case cannotIncreaseHole
    /// 必要な数の穴を開けることができなかった
    case cannotCreateHoles
    /// NumberPlace を作れなかった
    case cannotCreateNumberPlace(attemptNumber: Int)
    
    public var localizedDescription: String {
        
        switch self {
        case .cannotDetermineSquareNumber(let row, let column):
            return "\(row) 行 : \(column) 列 の数字を決められませんでした"
        case .cannotDetermineRowNumber(let row):
            return "\(row) 行目の数字を決められませんでした。"
        case .cannotProvideBoard:
            return "Board を準備できませんでした。"
        case .cannotIncreaseHole:
            return "必要な穴を増やすことができませんでした。"
        case .cannotCreateHoles:
            return "必要な数の穴を開けることができませんでした。"
        case .cannotCreateNumberPlace(let attemptNumber):
            return "\(attemptNumber)回の試行で、一意の解をもつナンプレを作れませんでした。"
        }
        
    }
    
}

