//
//  NumberPlaceSolver.swift
//  NumberPlaceMaker
//
//  Created by tosakakun on 2018/09/21.
//

import Foundation

/// 数独を解く構造体
public struct NumberPlaceSolver {
    
    /// 解の一意性チェックの最大試行回数
    private let maxUniquenessCheckAttemptNumber: Int
    
    /// イニシャライザ
    /// - Parameter maxUniquenessCheckAttemptNumber: 解の一意性チェックの最大試行回数
    public init(maxUniquenessCheckAttemptNumber: Int = 5) {
        self.maxUniquenessCheckAttemptNumber = maxUniquenessCheckAttemptNumber
    }
    
    /// 数独を解く
    ///
    /// - Parameters:
    ///   - board: 数独の盤面（解くのに成功すると答えの盤面になる）
    ///   - index: 調べ始めるマスの添字
    /// - Returns: 試行が成功したら .success / 施行が失敗したら .failure
    public func solve(board: Board, index: Int = 0) -> Board? {
        
        var nextHoleIndex: Int? = nil
        
        var board = board
        
        // 引数で受け取った index から次の穴を見つける
        for i in index..<board.numberOfSquares {
            if board.squares[i] == 0 {
                nextHoleIndex = i
                break
            }
        }
        
        guard let holeIndex = nextHoleIndex else {
            Logger.debug(message: "これ以上穴は見つかりませんでした。")
            return board
        }
        
        Logger.debug(message: "穴の index: \(holeIndex)")
        
        let point = board.squarePoint(from: holeIndex)
        let row = Int(point.y)
        let column = Int(point.x)
        
        // エリアに含まれる数字を取得
        let blockRow = row / board.blockNumberOfRows
        let blockColumn = column / board.blockNumberOfColumns
        let blockNumbers = board.block(at: CGPoint(x: blockColumn, y: blockRow))
        
        Logger.debug(message: "ブロック \(blockRow)行 \(blockColumn)列 の数字　\(blockNumbers)")
        
        // 行と列に含まれる数字を取得
        let rowNumbers = board.rowNumbers(at: row)
        let columnNumbers = board.columnNumbers(at: column)
        
        Logger.debug(message: "\(row)行 の数字 \(rowNumbers)")
        Logger.debug(message: "\(column)列 の数字 \(columnNumbers)")
        
        // 試す数字の配列
        var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        // 穴に1〜9の数字をランダムに選んで試す
        while numbers.count > 0 {
            
            let randomIndex = Int.random(in: 0..<numbers.count)
            let number = numbers.remove(at: randomIndex)
       
            // 条件判断
            //　エリアに同じ数字を含まない かつ 行に同じ数字を含まない かつ 列に同じ数字を含まない
            if !blockNumbers.contains(number) && !rowNumbers.contains(number) && !columnNumbers.contains(number) {
                
                Logger.debug(message: "仮採用: \(number)")
                board.squares[holeIndex] = number
                
                // 次の穴について再帰的に調べる
                if let result = solve(board: board, index: holeIndex + 1) {
                    // 成功したらその盤面を返す（ここに来るのは解けた（最後まで数字が埋まった）とき
                    return result
                } else {
                    // 次以降の穴について失敗したら仮採用を取り消し次のループへ
                    Logger.debug(message: "失敗: 仮採用 \(number) を取り消し")
                    board.squares[holeIndex] = 0
                }
                
            }
            
        }

        return nil
                
    }

    /// 数独の一意性をチェックする
    ///
    /// - Parameters:
    ///   - punchedBoard: 問題の盤面
    ///   - anserBoard: 正解の盤面
    /// - Returns: 一意の解を持つと判断 true / 重解が発見された false
    public func checkUniqueness(punchedBoard: Board, and anserBoard: Board) -> Bool {
        
        // TODO: maxUniquenessCheckAttemptNumber 回の重複チェックで十分か？要検討
        for i in 0..<maxUniquenessCheckAttemptNumber {
            
            Logger.info(message: "\(i + 1) 回目の一意性チェック =====")
            
            guard let solvedBoard = solve(board: punchedBoard, index: 0) else {
                Logger.info(message: "***** 解けませんでした *****")
                return false
            }
            
            if solvedBoard != anserBoard {
                Logger.info(message: "***** 異なる解が存在します *****")
                Logger.debug(message: solvedBoard)
                return false
            }
            
            Logger.debug(message: "OK")
            
        }
        
        Logger.info(message: "異なる解はなさそうです。")
        
        return true
        
    }
    
}
