//
//  BoardProvider.swift
//  NumberPlaceMaker
//
//  Created by tosakakun on 2018/09/20.
//

import Foundation

// 数独の盤面（穴が空いていない盤面）を準備する構造体
public struct BoardProvider {
    
    /// 盤面のマスの総数
    var numberOfSquares: Int {
        board.numberOfSquares
    }
    
    /// 盤面を作るための最大試行回数
    private let maxAttemptNumber: Int
    /// １つの行の数を並べるための最大試行回数
    private let maxRowAttemptNumber: Int
    /// １つのマス目の数字を決めるための最大試行回数
    private let maxSquareAttemptNumber: Int
    
    /// 数独の盤面
    private var board = Board()
    
    /// 数独の数字の配列
    private let seeds = [1, 2, 3, 4, 5, 6, 7, 8, 9]
    /// 一行に並べる数字を保持しておく配列
    private var numbers = [Int]()

    /// イニシャライザ
    /// - Parameters:
    ///   - maxAttemptNumber: 盤面を作るための最大試行回数
    ///   - maxRowAttemptNumber: １つの行の数を並べるための最大試行回数
    ///   - maxSquareAttemptNumber: １つのマス目の数字を決めるための最大試行回数
    public init(maxAttemptNumber: Int = 10, maxRowAttemptNumber: Int = 100, maxSquareAttemptNumber: Int = 100) {
        self.maxAttemptNumber = maxAttemptNumber
        self.maxRowAttemptNumber = maxRowAttemptNumber
        self.maxSquareAttemptNumber = maxSquareAttemptNumber
    }
    
    // MARK: - 数独作成ロジック

    /// 数独の盤面（数字で埋められたもの）を準備する
    /// - Returns: Board
    public mutating func provide() throws -> Board {
        
        // 数独の問題作成に成功するまで繰り返す
        // TODO: 試行回数を限定できないか要検討
        for counter in 0..<maxAttemptNumber {
            Logger.debug(message: "***** 作成開始 *****")
            
            do {
                
                try setNumbers()
                // 数独完成
                Logger.info(message: "\(counter) 回目の試行で盤面が準備できました。")
                Logger.debug(message: "***** 作成された数独（答え） *****")
                Logger.debug(message: board)
                
                return board
                
            } catch let error as NPError {
                Logger.info(message: error.localizedDescription)
            } catch {
                Logger.info(message: error.localizedDescription)
            }
            
            boardClear()

        }
        
        Logger.notice(message: "数独の数字を並べられませんでした。")
        throw NPError.cannotProvideBoard

    }
    
    /// 盤面に数字を並べる
    private mutating func setNumbers() throws {
        
        for row in 0..<board.numberOfRows {

            try attemptRowNumber(row: row)
            
        }
        
        Logger.debug(message: "作成処理終了")
        
    }
    
    
    /// 指定された行に数字を並べる処理を最大 maxRowAttemptNumber 回繰り返す
    /// - Parameter row: 数字を並べる行の index
    private mutating func attemptRowNumber(row: Int) throws {
        
        for _ in 0..<maxRowAttemptNumber {
            
            Logger.debug(message: "\(row) 行目 =============================")
            do {
                try determineRowNumber(of: row)
                Logger.debug(message: "\(row)行目完了")
                Logger.debug(message: board)
                return
                
            } catch let error as NPError {
                // この回ループで row 行目の数字を並べられなかった
                Logger.debug(message: error.localizedDescription)
            } catch {
                Logger.fault(message: error.localizedDescription)
            }
            
        }

        throw NPError.cannotDetermineRowNumber(row: row)
        
    }
    
    /// 指定された行の各マス目に数字を並べる処理
    /// - Parameter row: 行の index
    private mutating func determineRowNumber(of row: Int) throws {
        
        // 1〜9 の数字をコピーして保持する
        self.numbers = self.seeds
        
        board.clearRow(y: row)
        
        for column in 0..<board.numberOfColumns {
            try determineSquareNumber(row: row, column: column)
       }
        
    }
    
    
    /// 指定されたマス目の数字を決める処理
    /// - Parameters:
    ///   - row: 行の index
    ///   - column: 列の index
    private mutating func determineSquareNumber(row: Int, column: Int) throws {
        
        Logger.debug(message: "\(row)行 \(column)列 の処理 =====")
        
        // ブロックに含まれる数字を取得
        let blockRow = row / board.blockNumberOfRows
        let blockColumn = column / board.blockNumberOfColumns
        let blockNumbers = board.block(at: CGPoint(x: blockColumn, y: blockRow))
        
        Logger.debug(message: "ブロック \(blockRow)行 \(blockColumn)列 の数字　\(blockNumbers)")
        
        // 行と列に含まれる数字を取得
        let rowNumbers = board.rowNumbers(at: row)
        let columnNumbers = board.columnNumbers(at: column)
        
        Logger.debug(message: "\(row)行 の数字 \(rowNumbers)")
        Logger.debug(message: "\(column)列 の数字 \(columnNumbers)")
        
        for _ in 0..<maxSquareAttemptNumber {
            
            // 数独の数字の種からランダムに取得
            let randomIndex = Int.random(in: 0..<numbers.count)
            let number = numbers[randomIndex]
            
            Logger.debug(message: "種の残数 \(numbers.count)　\(numbers)")
            
            // 条件判断
            //　エリアに同じ数字を含まない かつ 行に同じ数字を含まない かつ 列に同じ数字を含まない
            if !blockNumbers.contains(number) && !rowNumbers.contains(number) && !columnNumbers.contains(number) {
                
                // ブロックと行と列にその数字が含まれていないので採用
                let index = board.squareIndex(from: CGPoint(x: column, y: row))
                board.squares[index] = number
                
                Logger.debug(message: "採用 \(number)")
                
                // 採用した数字を種の配列から削除
                numbers.remove(at: randomIndex)
                
                return
                
            }

        }
        
        // maxSquareAttemptNumber 回トライして決められなければ失敗とする
        Logger.debug(message: "！！！！！！\(row)行目の作成失敗！！！！！！")
        throw NPError.cannotDetermineSquareNumber(row: row, column: column)

    }
    
    /// 数独の盤面をすべてクリアする
    private mutating func boardClear() {
        board.clear()
    }

}
