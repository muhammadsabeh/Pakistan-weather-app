from flask import Flask, render_template, request, jsonify
import random

app = Flask(__name__, template_folder='templates', static_folder='static')

class TicTacToe:
    def __init__(self):
        self.board = ['' for _ in range(9)]
        self.current_player = 'X'
    
    def make_move(self, position, player):
        if 0 <= position < 9 and self.board[position] == '':
            self.board[position] = player
            return True
        return False
    
    def get_available_moves(self):
        return [i for i in range(9) if self.board[i] == '']
    
    def check_winner(self):
        winning_combinations = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]
        
        for combo in winning_combinations:
            if self.board[combo[0]] == self.board[combo[1]] == self.board[combo[2]] != '':
                return self.board[combo[0]]
        return None
    
    def is_board_full(self):
        return '' not in self.board
    
    def get_best_move(self):
        # AI logic - minimax algorithm for optimal play
        available = self.get_available_moves()
        if not available:
            return None
        
        best_score = float('-inf')
        best_move = None
        
        for move in available:
            self.board[move] = 'O'
            score = self.minimax(0, False)
            self.board[move] = ''
            
            if score > best_score:
                best_score = score
                best_move = move
        
        return best_move if best_move is not None else random.choice(available)
    
    def minimax(self, depth, is_maximizing):
        winner = self.check_winner()
        
        if winner == 'O':
            return 10 - depth
        elif winner == 'X':
            return depth - 10
        elif self.is_board_full():
            return 0
        
        if is_maximizing:
            best_score = float('-inf')
            for move in self.get_available_moves():
                self.board[move] = 'O'
                score = self.minimax(depth + 1, False)
                self.board[move] = ''
                best_score = max(score, best_score)
            return best_score
        else:
            best_score = float('inf')
            for move in self.get_available_moves():
                self.board[move] = 'X'
                score = self.minimax(depth + 1, True)
                self.board[move] = ''
                best_score = min(score, best_score)
            return best_score
    
    def reset(self):
        self.board = ['' for _ in range(9)]
        self.current_player = 'X'

game = TicTacToe()

@app.route('/')
def index():
    return render_template('tic_tac_toe.html')

@app.route('/api/make_move', methods=['POST'])
def make_move():
    data = request.json
    position = data.get('position')
    
    if not game.make_move(position, 'X'):
        return jsonify({'success': False, 'message': 'Invalid move'})
    
    winner = game.check_winner()
    if winner:
        return jsonify({
            'success': True,
            'board': game.board,
            'status': f'Player X wins!',
            'game_over': True
        })
    
    if game.is_board_full():
        return jsonify({
            'success': True,
            'board': game.board,
            'status': 'It\'s a draw!',
            'game_over': True
        })
    
    # AI move
    ai_move = game.get_best_move()
    if ai_move is not None:
        game.make_move(ai_move, 'O')
    
    winner = game.check_winner()
    if winner:
        return jsonify({
            'success': True,
            'board': game.board,
            'status': f'AI (O) wins!',
            'game_over': True
        })
    
    if game.is_board_full():
        return jsonify({
            'success': True,
            'board': game.board,
            'status': 'It\'s a draw!',
            'game_over': True
        })
    
    return jsonify({
        'success': True,
        'board': game.board,
        'status': 'Your turn',
        'game_over': False
    })

@app.route('/api/reset', methods=['POST'])
def reset():
    game.reset()
    return jsonify({
        'success': True,
        'board': game.board,
        'status': 'Game reset',
        'game_over': False
    })

@app.route('/api/board', methods=['GET'])
def get_board():
    return jsonify({
        'board': game.board,
        'status': 'Ready',
        'game_over': False
    })

if __name__ == '__main__':
    app.run(debug=True, port=5000)
