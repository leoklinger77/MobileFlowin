import 'package:first_app/utils/AvailableColors.dart';
import 'package:first_app/utils/AvailableIcons.dart';
import 'package:first_app/services/CategoryServices.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String _tipoSelecionado = 'Despesas';
  List<Map<String, dynamic>> _todasCategorias = [];
  List<Map<String, dynamic>> _categoriasDespesas = [];
  List<Map<String, dynamic>> _categoriasReceitas = [];
  List<Map<String, dynamic>> _categoriasVisiveis = [];
  Set<String> _categoriasExpandidas = {};

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = CategoryServices();
      final result = await service.fetchItems();
      _todasCategorias = List<Map<String, dynamic>>.from(result);

      _categoriasDespesas = _todasCategorias
          .where((c) => c['type'] == 1)
          .toList();
      _categoriasReceitas = _todasCategorias
          .where((c) => c['type'] == 0)
          .toList();

      _categoriasVisiveis = _tipoSelecionado == 'Despesas'
          ? _categoriasDespesas
          : _categoriasReceitas;

      setState(() {
        _loading = false;
      });
    } catch (e, stackTrace) {
      print('Erro: \$e\n\$stackTrace');
      setState(() {
        _error = 'Erro ao carregar categorias';
        _loading = false;
      });
    }
  }

  Future<String?> _createCategory({
    required String name,
    required int type,
    required int color,
    required String icon,
  }) async {
    try {
      final service = CategoryServices();
      return await service.createCategory(
        name: name,
        type: type,
        color: color,
        icon: icon,
      );
    } catch (e) {
      print('Erro ao criar categoria: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar categoria na API')),
      );
      return null;
    }
  }

  Future<void> _updateCategory({
    required String id,
    required String name,
    required int type,
    required int color,
    required String icon,
  }) async {
    try {
      final service = CategoryServices();
      await service.updateCategory(
        id: id,
        name: name,
        type: type,
        color: color,
        icon: icon,
      );
    } catch (e) {
      print('Erro ao editar categoria: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao editar categoria na API')),
      );
      return null;
    }
  }

  Future<String?> _createSubCategoria({
    required String id,
    required String name,
  }) async {
    try {
      final service = CategoryServices();
      return await service.createSubCategory(id: id, name: name);
    } catch (e) {
      print('Erro ao criar categoria: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar categoria na API')),
      );
      return null;
    }
  }

  Future<bool?> _updateSubCategoria({
    required String id,
    required String subId,
    required String name,
  }) async {
    try {
      final service = CategoryServices();
      await service.updateSubCategory(id: id, subId: subId, name: name);
      return true;
    } catch (e) {
      print('Erro ao criar categoria: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar categoria na API')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final corAtiva = _tipoSelecionado == 'Despesas' ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categorias',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: corAtiva,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : Column(
              children: [
                const SizedBox(height: 24),
                _buildToggleSelector(),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _categoriasVisiveis.length,
                    itemBuilder: (context, index) {
                      final cat = _categoriasVisiveis[index];
                      final id = cat['id']?.toString() ?? 'sem_id';
                      final subcats = List<Map<String, dynamic>>.from(
                        cat['subCategories'] ?? [],
                      );
                      final isExpanded = _categoriasExpandidas.contains(id);

                      return _buildCategoryCard(
                        cat: cat,
                        isExpanded: isExpanded,
                        subCategories: subcats,
                        onToggleExpand: () {
                          setState(() {
                            isExpanded
                                ? _categoriasExpandidas.remove(id)
                                : _categoriasExpandidas.add(id);
                          });
                        },
                        onAddSubcategory: () =>
                            _showAddSubcategoryDialog(index, id),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildToggleSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            _buildToggleButton('Despesas', Colors.red),
            _buildToggleButton('Receitas', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String tipo, Color cor) {
    final ativo = _tipoSelecionado == tipo;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tipoSelecionado = tipo;
            _categoriasVisiveis = tipo == 'Despesas'
                ? _categoriasDespesas
                : _categoriasReceitas;
            _categoriasExpandidas.clear();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: ativo ? cor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              tipo,
              style: TextStyle(
                color: ativo ? Colors.white : cor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required Map<String, dynamic> cat,
    required bool isExpanded,
    required List<Map<String, dynamic>> subCategories,
    required VoidCallback onToggleExpand,
    required VoidCallback onAddSubcategory,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpand,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AvailableColors.fromInt(cat['color']),
                    child: Icon(
                      AvailableIcons.parseIcon(cat['icon']) ??
                          Icons.category,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(cat['name'] ?? 'Sem nome')),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: onAddSubcategory,
                  ),
                  IconButton(
                    icon: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _editarCategoria(cat);
                        } else if (value == 'arquivar') {
                          _arquivarCategoria(cat);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'arquivar',
                          child: Text('Arquivar'),
                        ),
                      ],
                    ),

                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            ...subCategories.map(
              (subcat) => ListTile(
                contentPadding: const EdgeInsets.only(left: 72, right: 16),
                leading: const Icon(Icons.subdirectory_arrow_right),
                title: Text(subcat['name'] ?? 'Sem nome'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'editar') {
                      _editarSubcategoria(subcat, cat['id']);
                    } else if (value == 'arquivar') {
                      _arquivarSubcategoria(subcat, cat['id']);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),
                    const PopupMenuItem(
                      value: 'arquivar',
                      child: Text('Arquivar'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddSubcategoryDialog(int categoriaIndex, String catId) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Subcategoria'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nome da subcategoria'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final novaSubcat = controller.text.trim();

              if (novaSubcat.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Informe o nome da subcategoria'),
                  ),
                );
                return;
              }

              // Chamada da API
              final novoId = await _createSubCategoria(
                id: catId,
                name: novaSubcat,
              );

              if (novoId != null) {
                final novaSubcategoria = {
                  'id': novoId,
                  'name': novaSubcat,
                  'isActive': true,
                };

                // Atualiza todas as fontes de dados locais
                setState(() {
                  _categoriasVisiveis[categoriaIndex]['subCategories'].add(
                    novaSubcategoria,
                  );
                });

                // Fecha o diálogo e mostra confirmação
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Subcategoria "$novaSubcat" criada com sucesso',
                    ),
                  ),
                );
              } else {
                // Caso a API falhe
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao criar subcategoria')),
                );
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    Color? corSelecionada;
    IconData? iconSelecionado;

    final List<Color> coresDisponiveis = AvailableColors.allColors;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Categoria'),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da categoria',
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seletor de cor
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return Container(
                              height: 300,
                              padding: const EdgeInsets.all(16),
                              child: GridView.count(
                                crossAxisCount: 5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                children: coresDisponiveis.map((cor) {
                                  final selecionado = corSelecionada == cor;
                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() => corSelecionada = cor);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cor,
                                        shape: BoxShape.circle,
                                        border: selecionado
                                            ? Border.all(
                                                color: Colors.black,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.color_lens),
                          const SizedBox(width: 12),
                          Text(
                            corSelecionada != null
                                ? 'Cor selecionada'
                                : 'Selecionar cor',
                          ),
                          const Spacer(),
                          if (corSelecionada != null)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: corSelecionada,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Seletor de ícone
                    InkWell(
                      onTap: () {
                        _abrirSeletorDeIcones((icone) {
                          setModalState(() => iconSelecionado = icone);
                          Navigator.pop(context);
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.apps),
                          const SizedBox(width: 12),
                          Text(
                            iconSelecionado != null
                                ? 'Ícone selecionado'
                                : 'Selecionar ícone',
                          ),
                          const Spacer(),
                          if (iconSelecionado != null)
                            Icon(iconSelecionado, color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nome = nameController.text.trim();
                if (nome.isEmpty ||
                    corSelecionada == null ||
                    iconSelecionado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha todos os campos')),
                  );
                  return;
                }

                final tipo = _tipoSelecionado == 'Despesas' ? 1 : 0;
                final corInt = AvailableColors.allColors.indexOf(
                  corSelecionada!,
                );
                final iconeNome = iconSelecionado!.codePoint.toString();

                final id = await _createCategory(
                  name: nome,
                  type: tipo,
                  color: corInt,
                  icon: iconeNome,
                );

                if (id != null) {
                  setState(() {
                    _categoriasVisiveis.add({
                      'id': id,
                      'name': nome,
                      'type': tipo,
                      'color': {
                        'hex':
                            '#${corSelecionada!.value.toRadixString(16).substring(2)}',
                      },
                      'icon': iconSelecionado,
                      'subCategories': [],
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _abrirSeletorDeIcones(Function(IconData) onSelecionarIcone) {
    final List<IconData> todosOsIcones = AvailableIcons.allIcons;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: todosOsIcones.map((icon) {
              return GestureDetector(
                onTap: () => onSelecionarIcone(icon),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, size: 28),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _editarCategoria(Map<String, dynamic> cat) {
    final TextEditingController nameController = TextEditingController(
      text: cat['name'],
    );
    Color? corSelecionada =Colors.blue; //AvailableColors.getCategoriaColor(cat);
    IconData? iconSelecionado = AvailableIcons.parseIcon(cat['icon']);
    final List<Color> coresDisponiveis = AvailableColors.allColors;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova Categoria'),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da categoria',
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Seletor de cor
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return Container(
                              height: 300,
                              padding: const EdgeInsets.all(16),
                              child: GridView.count(
                                crossAxisCount: 5,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                children: coresDisponiveis.map((cor) {
                                  final selecionado = corSelecionada == cor;
                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() => corSelecionada = cor);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: cor,
                                        shape: BoxShape.circle,
                                        border: selecionado
                                            ? Border.all(
                                                color: Colors.black,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.color_lens),
                          const SizedBox(width: 12),
                          Text(
                            corSelecionada != null
                                ? 'Cor selecionada'
                                : 'Selecionar cor',
                          ),
                          const Spacer(),
                          if (corSelecionada != null)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: corSelecionada,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Seletor de ícone
                    InkWell(
                      onTap: () {
                        _abrirSeletorDeIcones((icone) {
                          setModalState(() => iconSelecionado = icone);
                          Navigator.pop(context);
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.apps),
                          const SizedBox(width: 12),
                          Text(
                            iconSelecionado != null
                                ? 'Ícone selecionado'
                                : 'Selecionar ícone',
                          ),
                          const Spacer(),
                          if (iconSelecionado != null)
                            Icon(iconSelecionado, color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nome = nameController.text.trim();
                if (nome.isEmpty ||
                    corSelecionada == null ||
                    iconSelecionado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preencha todos os campos')),
                  );
                  return;
                }

                final tipo = _tipoSelecionado == 'Despesas' ? 1 : 0;
                final corInt = AvailableColors.allColors.indexOf(
                  corSelecionada!,
                );
                final iconeNome = iconSelecionado!.codePoint.toString();

                try {
                  await _updateCategory(
                    id: cat['id'].toString(),
                    name: nome,
                    type: tipo,
                    color: corInt,
                    icon: iconeNome,
                  );

                  if (!mounted) return;

                  Navigator.pop(context); // Fecha o diálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Categoria atualizada com sucesso'),
                    ),
                  );
                } catch (e) {
                  String mensagemErro = 'Erro ao atualizar categoria';

                  // Caso o erro venha como Map
                  if (e is Map && e['data'] is List) {
                    final mensagens = (e['data'] as List)
                        .map((item) => item['message']?.toString() ?? '')
                        .where((m) => m.isNotEmpty)
                        .toList();
                    mensagemErro = mensagens.join('\n');
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(mensagemErro)));
                }
              },

              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _arquivarCategoria(Map<String, dynamic> cat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arquivar Categoria'),
        content: const Text('Tem certeza que deseja arquivar esta categoria?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // try {
              //   final service = CategoryServicesApi();
              //   await service.archiveCategory(
              //     cat['id'],
              //   ); // Supondo que tenha esse método
              //   setState(() {
              //     _categoriasVisiveis.remove(cat);
              //   });
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(content: Text('Categoria arquivada')),
              //   );
              // } catch (e) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(content: Text('Erro ao arquivar categoria')),
              //   );
              // }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _editarSubcategoria(Map<String, dynamic> subcat, String categoriaId) {
    final controller = TextEditingController(text: subcat['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Subcategoria'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nome da subcategoria'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final novoNome = controller.text.trim();
              if (novoNome.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Informe um nome válido')),
                );
                return;
              }

              final sucesso = await _updateSubCategoria(
                id: categoriaId,
                subId: subcat['id'],
                name: novoNome,
              );

              if (sucesso!) {
                setState(() {
                  subcat['name'] = novoNome;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Subcategoria atualizada com sucesso'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao atualizar subcategoria'),
                  ),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _arquivarSubcategoria(
    Map<String, dynamic> subcat,
    String categoriaId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arquivar Subcategoria'),
        content: Text('Deseja arquivar a subcategoria "${subcat['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Arquivar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // final sucesso = await _archiveSubCategoria(id: subcat['id']);
      // if (sucesso) {
      //   setState(() {
      //     subcat['isActive'] = false;
      //   });
      //   ScaffoldMessenger.of(
      //     context,
      //   ).showSnackBar(const SnackBar(content: Text('Subcategoria arquivada')));
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Erro ao arquivar subcategoria')),
      //   );
      // }
    }
  }
}
