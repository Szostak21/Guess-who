import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/deck.dart';
import '../cubit/lobby_cubit.dart';
import 'create_lobby_screen.dart';
import 'join_lobby_screen.dart';

/// Screen for choosing to host or join an online game
class OnlineModeScreen extends StatefulWidget {
  final Deck deck;

  const OnlineModeScreen({
    super.key,
    required this.deck,
  });

  @override
  State<OnlineModeScreen> createState() => _OnlineModeScreenState();
}

class _OnlineModeScreenState extends State<OnlineModeScreen> {
  final _nameController = TextEditingController(text: 'Player');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Mode'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Icon
                const Icon(
                  Icons.wifi,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Play Online',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect with another player on the same network',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 40),

                // Player name input
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLength: 20,
                ),

                const SizedBox(height: 24),

                // Deck info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.style, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Deck',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.deck.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${widget.deck.characters.length} characters',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Host game card (matches selected deck style)
                Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: _hostGame,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_tethering,
                              size: 28, color: Colors.blue,),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'HOST GAME',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Create a lobby and share the code',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Info card
                Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.amber.shade900,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Both players must be connected to the same WiFi network',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hostGame() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => LobbyCubit(),
          child: CreateLobbyScreen(
            deck: widget.deck,
            playerName: name,
          ),
        ),
      ),
    );
  }
}
