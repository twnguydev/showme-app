// mobile/lib/features/crm/bloc/crm_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../shared/models/contact_exchange.dart';
import '../../../shared/models/contact_stats.dart';
import '../../../shared/models/card.dart';

// Events
abstract class CrmEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CrmStatsRequested extends CrmEvent {}

class CrmContactsRequested extends CrmEvent {}

class CrmContactDetailsRequested extends CrmEvent {
  final int contactId;
  
  CrmContactDetailsRequested(this.contactId);
  
  @override
  List<Object> get props => [contactId];
}

class CrmExportRequested extends CrmEvent {
  final String format; // 'csv', 'excel', 'pdf'
  
  CrmExportRequested(this.format);
  
  @override
  List<Object> get props => [format];
}

class CrmFilterChanged extends CrmEvent {
  final CrmFilter filter;
  
  CrmFilterChanged(this.filter);
  
  @override
  List<Object> get props => [filter];
}

class CrmRefreshRequested extends CrmEvent {}

// States
abstract class CrmState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CrmInitial extends CrmState {}

class CrmLoading extends CrmState {}

class CrmStatsLoaded extends CrmState {
  final ContactStats stats;
  
  CrmStatsLoaded(this.stats);
  
  @override
  List<Object> get props => [stats];
}

class CrmContactsLoaded extends CrmState {
  final List<ContactExchange> contacts;
  final CrmFilter? currentFilter;
  
  CrmContactsLoaded(this.contacts, {this.currentFilter});
  
  @override
  List<Object?> get props => [contacts, currentFilter];
}

class CrmContactDetailsLoaded extends CrmState {
  final ContactExchange contact;
  
  CrmContactDetailsLoaded(this.contact);
  
  @override
  List<Object> get props => [contact];
}

class CrmDataLoaded extends CrmState {
  final ContactStats stats;
  final List<ContactExchange> contacts;
  final CrmFilter? currentFilter;
  
  CrmDataLoaded(this.stats, this.contacts, {this.currentFilter});
  
  @override
  List<Object?> get props => [stats, contacts, currentFilter];
}

class CrmExportSuccess extends CrmState {
  final String message;
  final String? downloadUrl;
  
  CrmExportSuccess(this.message, {this.downloadUrl});
  
  @override
  List<Object?> get props => [message, downloadUrl];
}

class CrmError extends CrmState {
  final String message;
  
  CrmError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Filter model
class CrmFilter extends Equatable {
  final ExchangeMethod? method;
  final DeviceType? deviceType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? location;
  final bool? qualifiedLeadsOnly;

  const CrmFilter({
    this.method,
    this.deviceType,
    this.startDate,
    this.endDate,
    this.location,
    this.qualifiedLeadsOnly,
  });

  @override
  List<Object?> get props => [
    method,
    deviceType,
    startDate,
    endDate,
    location,
    qualifiedLeadsOnly,
  ];

  CrmFilter copyWith({
    ExchangeMethod? method,
    DeviceType? deviceType,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    bool? qualifiedLeadsOnly,
  }) {
    return CrmFilter(
      method: method ?? this.method,
      deviceType: deviceType ?? this.deviceType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      qualifiedLeadsOnly: qualifiedLeadsOnly ?? this.qualifiedLeadsOnly,
    );
  }

  bool get hasActiveFilters {
    return method != null ||
        deviceType != null ||
        startDate != null ||
        endDate != null ||
        location != null ||
        qualifiedLeadsOnly != null;
  }

  static const CrmFilter empty = CrmFilter();
}

// Bloc
class CrmBloc extends Bloc<CrmEvent, CrmState> {
  final List<ContactExchange> _allContacts = [];
  ContactStats? _cachedStats;
  CrmFilter _currentFilter = CrmFilter.empty;

  CrmBloc() : super(CrmInitial()) {
    on<CrmStatsRequested>(_onStatsRequested);
    on<CrmContactsRequested>(_onContactsRequested);
    on<CrmContactDetailsRequested>(_onContactDetailsRequested);
    on<CrmExportRequested>(_onExportRequested);
    on<CrmFilterChanged>(_onFilterChanged);
    on<CrmRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onStatsRequested(
    CrmStatsRequested event,
    Emitter<CrmState> emit,
  ) async {
    emit(CrmLoading());
    
    try {
      // Utiliser le cache si disponible, sinon charger
      if (_cachedStats != null) {
        emit(CrmStatsLoaded(_cachedStats!));
        return;
      }

      await Future.delayed(const Duration(milliseconds: 300));
      _cachedStats = ContactStats.demo();
      
      emit(CrmStatsLoaded(_cachedStats!));
    } catch (e) {
      emit(CrmError('Erreur lors du chargement des statistiques: ${e.toString()}'));
    }
  }

  Future<void> _onContactsRequested(
    CrmContactsRequested event,
    Emitter<CrmState> emit,
  ) async {
    emit(CrmLoading());
    
    try {
      if (_allContacts.isEmpty) {
        await _loadDemoContacts();
      }

      final filteredContacts = _applyFilter(_allContacts, _currentFilter);
      emit(CrmContactsLoaded(filteredContacts, currentFilter: _currentFilter));
    } catch (e) {
      emit(CrmError('Erreur lors du chargement des contacts: ${e.toString()}'));
    }
  }

  Future<void> _onContactDetailsRequested(
    CrmContactDetailsRequested event,
    Emitter<CrmState> emit,
  ) async {
    emit(CrmLoading());
    
    try {
      final contact = _allContacts.firstWhere(
        (c) => c.id == event.contactId,
        orElse: () => throw Exception('Contact non trouvé'),
      );
      
      emit(CrmContactDetailsLoaded(contact));
    } catch (e) {
      emit(CrmError('Erreur lors du chargement du contact: ${e.toString()}'));
    }
  }

  Future<void> _onExportRequested(
    CrmExportRequested event,
    Emitter<CrmState> emit,
  ) async {
    emit(CrmLoading());
    
    try {
      // Simulation d'export
      await Future.delayed(const Duration(seconds: 2));
      
      final message = 'Export ${event.format.toUpperCase()} généré avec succès';
      emit(CrmExportSuccess(message, downloadUrl: 'https://example.com/export.${event.format}'));
    } catch (e) {
      emit(CrmError('Erreur lors de l\'export: ${e.toString()}'));
    }
  }

  Future<void> _onFilterChanged(
    CrmFilterChanged event,
    Emitter<CrmState> emit,
  ) async {
    _currentFilter = event.filter;
    
    try {
      final filteredContacts = _applyFilter(_allContacts, _currentFilter);
      emit(CrmContactsLoaded(filteredContacts, currentFilter: _currentFilter));
    } catch (e) {
      emit(CrmError('Erreur lors de l\'application du filtre: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshRequested(
    CrmRefreshRequested event,
    Emitter<CrmState> emit,
  ) async {
    emit(CrmLoading());
    
    try {
      // Recharger les données
      await _loadDemoContacts();
      _cachedStats = ContactStats.demo();
      
      final filteredContacts = _applyFilter(_allContacts, _currentFilter);
      emit(CrmDataLoaded(_cachedStats!, filteredContacts, currentFilter: _currentFilter));
    } catch (e) {
      emit(CrmError('Erreur lors du rafraîchissement: ${e.toString()}'));
    }
  }

  Future<void> _loadDemoContacts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    _allContacts.clear();
    _allContacts.addAll([
      ContactExchange(
        id: 1,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        geoLocation: {'city': 'Paris', 'country': 'France', 'lat': 48.8566, 'lng': 2.3522},
        userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)',
        referrer: ExchangeMethod.nfc,
        openedOnWallet: true,
        contactAdded: true,
        emailSubmitted: 'marie.martin@example.com',
        deviceType: DeviceType.ios,
        card: Card.demo(),
        visitor: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ContactExchange(
        id: 2,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        geoLocation: {'city': 'Lyon', 'country': 'France', 'lat': 45.7640, 'lng': 4.8357},
        userAgent: 'Mozilla/5.0 (Linux; Android 13)',
        referrer: ExchangeMethod.qr,
        openedOnWallet: false,
        contactAdded: true,
        emailSubmitted: 'pierre.durand@company.com',
        deviceType: DeviceType.android,
        card: Card.demo(),
        visitor: null,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ContactExchange(
        id: 3,
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        geoLocation: {'city': 'Marseille', 'country': 'France', 'lat': 43.2965, 'lng': 5.3698},
        userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
        referrer: ExchangeMethod.link,
        openedOnWallet: false,
        contactAdded: false,
        emailSubmitted: null,
        deviceType: DeviceType.web,
        card: Card.demo(),
        visitor: null,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ContactExchange(
        id: 4,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        geoLocation: {'city': 'Toulouse', 'country': 'France', 'lat': 43.6047, 'lng': 1.4442},
        userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X)',
        referrer: ExchangeMethod.kiosk,
        openedOnWallet: true,
        contactAdded: true,
        emailSubmitted: 'sophie.bernard@startup.fr',
        deviceType: DeviceType.ios,
        card: Card.demo(),
        visitor: null,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);
  }

  List<ContactExchange> _applyFilter(List<ContactExchange> contacts, CrmFilter filter) {
    var filtered = contacts;

    if (filter.method != null) {
      filtered = filtered.where((c) => c.referrer == filter.method).toList();
    }

    if (filter.deviceType != null) {
      filtered = filtered.where((c) => c.deviceType == filter.deviceType).toList();
    }

    if (filter.startDate != null) {
      filtered = filtered.where((c) => c.timestamp.isAfter(filter.startDate!)).toList();
    }

    if (filter.endDate != null) {
      filtered = filtered.where((c) => c.timestamp.isBefore(filter.endDate!)).toList();
    }

    if (filter.location != null && filter.location!.isNotEmpty) {
      filtered = filtered.where((c) => 
        c.locationName.toLowerCase().contains(filter.location!.toLowerCase())
      ).toList();
    }

    if (filter.qualifiedLeadsOnly == true) {
      filtered = filtered.where((c) => c.isQualifiedLead).toList();
    }

    return filtered;
  }

  // Méthodes utilitaires
  int get totalContacts => _allContacts.length;
  int get qualifiedLeads => _allContacts.where((c) => c.isQualifiedLead).length;
  
  List<ContactExchange> getContactsByMethod(ExchangeMethod method) {
    return _allContacts.where((c) => c.referrer == method).toList();
  }

  List<ContactExchange> getRecentContacts(int limit) {
    final sorted = List<ContactExchange>.from(_allContacts)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  Map<String, int> getLocationBreakdown() {
    final breakdown = <String, int>{};
    for (final contact in _allContacts) {
      final location = contact.locationName;
      breakdown[location] = (breakdown[location] ?? 0) + 1;
    }
    return breakdown;
  }
}