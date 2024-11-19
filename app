# Create a new repository
git init
git add .
git commit -m "Initial commit of Padel Scheduler"
git remote add origin https://github.com/yourusername/padel-scheduler.git
git push -u origin main

import React, { useState } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { X, Plus, Check, Star, ChevronDown, ChevronUp } from 'lucide-react';

const PadelScheduler = () => {
  const [players, setPlayers] = useState([]);
  const [newPlayer, setNewPlayer] = useState({ 
    name: '', 
    availability: [],
    preferredSlots: []
  });
  const [selectedDay, setSelectedDay] = useState('Monday');
  const [selectionMode, setSelectionMode] = useState('available');
  const [expandedPlayer, setExpandedPlayer] = useState(null);
  
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  const generateTimeSlots = () => {
    const slots = [];
    for (let hour = 9; hour <= 20; hour++) {
      for (let minute of ['00', '30']) {
        if (hour === 20 && minute === '30') continue;
        slots.push(`${hour.toString().padStart(2, '0')}:${minute}`);
      }
    }
    return slots;
  };

  const timeSlots = generateTimeSlots();

  const getFullSlot = (day, time) => `${day} ${time}`;

  const addPlayer = () => {
    if (newPlayer.name.trim() && (newPlayer.availability.length > 0 || newPlayer.preferredSlots.length > 0)) {
      setPlayers([...players, newPlayer]);
      setNewPlayer({ name: '', availability: [], preferredSlots: [] });
    }
  };

  const toggleTimeSlot = (slot) => {
    if (selectionMode === 'available') {
      setNewPlayer(prev => ({
        ...prev,
        availability: prev.availability.includes(slot)
          ? prev.availability.filter(s => s !== slot)
          : [...prev.availability, slot]
      }));
    } else {
      setNewPlayer(prev => ({
        ...prev,
        preferredSlots: prev.preferredSlots.includes(slot)
          ? prev.preferredSlots.filter(s => s !== slot)
          : [...prev.preferredSlots, slot]
      }));
    }
  };

  const removePlayer = (playerIndex) => {
    setPlayers(players.filter((_, index) => index !== playerIndex));
    if (expandedPlayer === playerIndex) setExpandedPlayer(null);
  };

  const findCommonSlots = () => {
    const allSlots = days.flatMap(day => 
      timeSlots.map(time => getFullSlot(day, time))
    );
    
    return allSlots.map(slot => {
      const availablePlayers = players.filter(player => 
        player.availability.includes(slot) || player.preferredSlots.includes(slot)
      );
      const preferredCount = availablePlayers.filter(player => 
        player.preferredSlots.includes(slot)
      ).length;
      
      return {
        slot,
        playerCount: availablePlayers.length,
        preferredCount,
        isViable: availablePlayers.length >= 4
      };
    }).filter(slotInfo => slotInfo.isViable)
    .sort((a, b) => b.preferredCount - a.preferredCount);
  };

  const getSlotStyle = (slot) => {
    if (selectionMode === 'preferred' && newPlayer.preferredSlots.includes(slot)) {
      return "bg-yellow-400 text-black hover:bg-yellow-500";
    }
    if (selectionMode === 'available' && newPlayer.availability.includes(slot)) {
      return "bg-blue-500 hover:bg-blue-600";
    }
    return "bg-white hover:bg-gray-100 border-2";
  };

  const groupSlotsByDay = (slots) => {
    const grouped = {};
    slots.forEach(slot => {
      const [day, time] = slot.split(' ');
      if (!grouped[day]) grouped[day] = [];
      grouped[day].push(time);
    });
    return grouped;
  };

  // Helper to check if button should be enabled
  const isAddButtonDisabled = !newPlayer.name || (newPlayer.availability.length === 0 && newPlayer.preferredSlots.length === 0);

  // Modified button styles function
  const getAddButtonStyles = (isDisabled) => {
    if (!isDisabled) {
      return "gap-2 bg-emerald-500 hover:bg-emerald-600 text-white font-medium shadow-lg hover:shadow-xl transition-all duration-200 transform hover:-translate-y-0.5 relative after:absolute after:inset-0 after:z-[-1] after:bg-emerald-400 after:blur-sm after:opacity-50";
    }
    return "gap-2 bg-gray-400 text-white font-medium opacity-50 cursor-not-allowed";
  };

  const commonSlots = findCommonSlots();

  return (
    <Card className="w-full max-w-6xl">
      <CardHeader>
        <CardTitle>Padel Game Scheduler</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="mb-6 p-4 border rounded-lg">
          <div className="flex justify-between items-start mb-4">
            <div>
              <h3 className="text-lg font-medium mb-2">Add New Player</h3>
              <div className="flex gap-2">
                <input
                  type="text"
                  value={newPlayer.name}
                  onChange={(e) => setNewPlayer({ ...newPlayer, name: e.target.value })}
                  placeholder="Player name"
                  className="border p-2 rounded"
                />
                <Button 
                  onClick={() => setSelectionMode('available')}
                  variant={selectionMode === 'available' ? "default" : "outline"}
                  className="gap-2"
                >
                  <Check className="w-4 h-4" />
                  Available
                </Button>
                <Button 
                  onClick={() => setSelectionMode('preferred')}
                  variant={selectionMode === 'preferred' ? "default" : "outline"}
                  className="gap-2"
                >
                  <Star className="w-4 h-4" />
                  Preferred
                </Button>
              </div>
            </div>
            <Button 
              onClick={addPlayer} 
              disabled={isAddButtonDisabled}
              className={getAddButtonStyles(isAddButtonDisabled)}
            >
              <Plus className="w-5 h-5" />
              Add Player
            </Button>
          </div>

          <div className="mb-4 flex gap-2 flex-wrap">
            {days.map(day => (
              <Button
                key={day}
                variant={selectedDay === day ? "default" : "outline"}
                onClick={() => setSelectedDay(day)}
                className="text-sm"
              >
                {day}
              </Button>
            ))}
          </div>

          <div className="grid grid-cols-2 md:grid-cols-6 gap-2">
            {timeSlots.map(time => {
              const fullSlot = getFullSlot(selectedDay, time);
              return (
                <Button
                  key={fullSlot}
                  variant="outline"
                  onClick={() => toggleTimeSlot(fullSlot)}
                  className={`text-sm ${getSlotStyle(fullSlot)}`}
                >
                  {time}
                </Button>
              );
            })}
          </div>
        </div>

        <div className="mb-6">
          <h3 className="text-lg font-medium mb-2">Current Players ({players.length})</h3>
          <div className="space-y-2">
            {players.map((player, index) => (
              <div key={index} className="border rounded overflow-hidden">
                <div className="flex items-center justify-between p-2 bg-gray-50">
                  <div>
                    <span className="font-medium">{player.name}</span>
                    <span className="text-sm text-gray-500 ml-2">
                      ({player.availability.length} available, {player.preferredSlots.length} preferred)
                    </span>
                  </div>
                  <div className="flex gap-2">
                    <Button 
                      variant="ghost" 
                      onClick={() => setExpandedPlayer(expandedPlayer === index ? null : index)}
                    >
                      {expandedPlayer === index ? 
                        <ChevronUp className="w-4 h-4" /> : 
                        <ChevronDown className="w-4 h-4" />
                      }
                    </Button>
                    <Button variant="ghost" onClick={() => removePlayer(index)}>
                      <X className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
                
                {expandedPlayer === index && (
                  <div className="p-4 bg-white">
                    <div className="mb-4">
                      <h4 className="font-medium mb-2 flex items-center gap-2">
                        <Check className="w-4 h-4 text-blue-500" />
                        Available Times
                      </h4>
                      {Object.entries(groupSlotsByDay(player.availability)).map(([day, times]) => (
                        <div key={day} className="mb-2">
                          <div className="font-medium text-sm text-gray-600">{day}</div>
                          <div className="flex flex-wrap gap-2 mt-1">
                            {times.sort().map(time => (
                              <span key={time} className="px-2 py-1 bg-blue-100 text-blue-800 rounded text-sm">
                                {time}
                              </span>
                            ))}
                          </div>
                        </div>
                      ))}
                    </div>
                    
                    <div>
                      <h4 className="font-medium mb-2 flex items-center gap-2">
                        <Star className="w-4 h-4 text-yellow-500" />
                        Preferred Times
                      </h4>
                      {Object.entries(groupSlotsByDay(player.preferredSlots)).map(([day, times]) => (
                        <div key={day} className="mb-2">
                          <div className="font-medium text-sm text-gray-600">{day}</div>
                          <div className="flex flex-wrap gap-2 mt-1">
                            {times.sort().map(time => (
                              <span key={time} className="px-2 py-1 bg-yellow-100 text-yellow-800 rounded text-sm">
                                {time}
                              </span>
                            ))}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>

        <div>
          <h3 className="text-lg font-medium mb-2">Available Game Slots</h3>
          {commonSlots.length > 0 ? (
            <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
              {commonSlots.map(({ slot, playerCount, preferredCount }) => (
                <div 
                  key={slot} 
                  className={`p-2 rounded flex items-center justify-between ${
                    preferredCount > 0 ? 'bg-yellow-100' : 'bg-green-100'
                  }`}
                >
                  <div className="flex items-center">
                    <Check className="w-4 h-4 text-green-600 mr-2" />
                    {slot}
                  </div>
                  <div className="flex items-center gap-1">
                    <span className="text-sm text-gray-600">{playerCount}</span>
                    {preferredCount > 0 && (
                      <div className="flex items-center">
                        <Star className="w-4 h-4 text-yellow-500" />
                        <span className="text-sm text-yellow-600">{preferredCount}</span>
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500">No common slots found for 4 players yet.</p>
          )}
        </div>
      </CardContent>
    </Card>
  );
};

export default PadelScheduler;
