import React, { useState } from 'react';

const WeeklyTimelineView = () => {
  const [selectedTask, setSelectedTask] = useState({ day: 5, id: 'gym' });
  
  const days = [
    { day: 'Mon', date: 29, month: 'Dec' },
    { day: 'Tue', date: 30, month: 'Dec' },
    { day: 'Wed', date: 31, month: 'Dec' },
    { day: 'Thu', date: 1, month: 'Jan' },
    { day: 'Fri', date: 2, month: 'Jan' },
    { day: 'Sat', date: 3, month: 'Jan', isToday: true },
    { day: 'Sun', date: 4, month: 'Jan' },
  ];

  // Color palette - refined, sophisticated
  const colors = {
    coral: '#E8847C',      // Warm coral for morning routines
    sage: '#7BAE7F',       // Sage green for wellness
    sky: '#6BA3D6',        // Sky blue for work
    lavender: '#9B8EC2',   // Lavender for creative
    amber: '#D4A853',      // Amber for meals
    rose: '#C97B8E',       // Rose for personal
    slate: '#64748B',      // Slate for neutral
    night: '#4A5568',      // Night mode indicator
  };

  // Weekly schedule data
  const weekSchedule = [
    { // Monday
      tasks: [
        { id: 'workout', time: 5, duration: 1, color: colors.coral, icon: '◎', label: 'Workout' },
        { id: 'wake', time: 6.5, duration: 0.5, color: colors.coral, icon: '◐', label: 'Wake Up' },
        { id: 'work', time: 9, duration: 4, color: colors.sky, icon: '◈', label: 'Deep Work' },
        { id: 'lunch', time: 13, duration: 1, color: colors.amber, icon: '◉', label: 'Lunch' },
        { id: 'meeting', time: 15, duration: 2, color: colors.lavender, icon: '◇', label: 'Meeting' },
        { id: 'errands', time: 17, duration: 1.5, color: colors.rose, icon: '◆', label: 'Errands' },
        { id: 'sleep', time: 22, duration: 1, color: colors.night, icon: '◑', label: 'Sleep' },
      ]
    },
    { // Tuesday
      tasks: [
        { id: 'wake', time: 6.5, duration: 0.5, color: colors.coral, icon: '◐', label: 'Wake Up' },
        { id: 'work', time: 9, duration: 4, color: colors.sky, icon: '◈', label: 'Deep Work' },
        { id: 'lunch', time: 13, duration: 1, color: colors.amber, icon: '◉', label: 'Lunch' },
        { id: 'creative', time: 14.5, duration: 2.5, color: colors.lavender, icon: '✦', label: 'Creative' },
        { id: 'sleep', time: 22, duration: 1, color: colors.night, icon: '◑', label: 'Sleep' },
      ]
    },
    { // Wednesday
      tasks: [
        { id: 'wake', time: 6.5, duration: 0.5, color: colors.coral, icon: '◐', label: 'Wake Up' },
        { id: 'yoga', time: 7, duration: 1, color: colors.sage, icon: '❋', label: 'Yoga' },
        { id: 'work', time: 9, duration: 4, color: colors.sky, icon: '◈', label: 'Deep Work' },
        { id: 'lunch', time: 13, duration: 1, color: colors.amber, icon: '◉', label: 'Lunch' },
        { id: 'review', time: 15, duration: 2, color: colors.lavender, icon: '◇', label: 'Review' },
        { id: 'sleep', time: 22, duration: 1, color: colors.night, icon: '◑', label: 'Sleep' },
      ]
    },
    { // Thursday
      tasks: [
        { id: 'wake', time: 6.5, duration: 0.5, color: colors.coral, icon: '◐', label: 'Wake Up' },
        { id: 'work', time: 9, duration: 4, color: colors.sky, icon: '◈', label: 'Deep Work' },
        { id: 'lunch', time: 13, duration: 1, color: colors.amber, icon: '◉', label: 'Lunch' },
        { id: 'planning', time: 14.5, duration: 1.5, color: colors.lavender, icon: '◈', label: 'Planning' },
        { id: 'gym', time: 17, duration: 1.5, color: colors.sage, icon: '◎', label: 'Gym' },
        { id: 'sleep', time: 22, duration: 1, color: colors.night, icon: '◑', label: 'Sleep' },
      ]
    },
    { // Friday
      tasks: [
        { id: 'wake', time: 6.5, duration: 0.5, color: colors.coral, icon: '◐', label: 'Wake Up' },
        { id: 'work', time: 9, duration: 3, color: colors.sky, icon: '◈', label: 'Deep Work' },
        { id: 'lunch', time: 12.5, duration: 1, color: colors.amber, icon: '◉', label: 'Lunch' },
        { id: 'wrap', time: 14, duration: 2, color: colors.sky, icon: '◈', label: 'Wrap Up' },
        { id: 'social', time: 18, duration: 3, color: colors.rose, icon: '♡', label: 'Social' },
        { id: 'sleep', time: 23, duration: 1, color: colors.night, icon: '◑', label: 'Sleep' },
      ]
    },
    { // Saturday - Today
      tasks: [
        { id: 'wake', time: 7, duration: 0.5, color: colors.coral, icon: '◐', label: 'Wake Up', faded: true },
        { id: 'gym', time: 12, duration: 1, color: colors.sage, icon: '◎', label: 'Gym' },
        { id: 'sleep', time: 22, duration: 1, color: colors.night, icon: '◑', label: 'Sleep' },
      ]
    },
    { // Sunday
      tasks: [
        { id: 'wake', time: 8, duration: 0.5, color: colors.coral, icon: '◐', label: 'Wake Up' },
        { id: 'brunch', time: 10, duration: 1.5, color: colors.amber, icon: '◉', label: 'Brunch' },
        { id: 'relax', time: 14, duration: 3, color: colors.lavender, icon: '❋', label: 'Relax' },
        { id: 'prep', time: 18, duration: 1, color: colors.slate, icon: '◇', label: 'Week Prep' },
        { id: 'sleep', time: 22, duration: 1, color: colors.night, icon: '◑', label: 'Sleep' },
      ]
    },
  ];

  const hours = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];
  const timelineHeight = 520;
  const hourHeight = timelineHeight / (hours.length);
  
  const getTaskPosition = (time) => {
    return ((time - 5) / (23 - 5)) * timelineHeight;
  };

  const getTaskHeight = (duration) => {
    return (duration / (23 - 5)) * timelineHeight;
  };

  const currentTimePosition = getTaskPosition(11.5); // 11:30 AM

  const selectedTaskData = selectedTask 
    ? weekSchedule[selectedTask.day]?.tasks.find(t => t.id === selectedTask.id)
    : null;

  const formatTime = (time) => {
    const hour = Math.floor(time);
    const min = (time % 1) * 60;
    const period = hour >= 12 ? 'PM' : 'AM';
    const displayHour = hour > 12 ? hour - 12 : hour === 0 ? 12 : hour;
    return `${displayHour}:${min === 0 ? '00' : min.toString().padStart(2, '0')} ${period}`;
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-stone-100 via-stone-50 to-orange-50/30 p-8">
      {/* iPhone Frame */}
      <div className="relative w-[390px] h-[844px] bg-black rounded-[55px] p-3 shadow-2xl">
        {/* Screen */}
        <div className="relative w-full h-full bg-[#F8F7F4] rounded-[45px] overflow-hidden">
          
          {/* Dynamic Island */}
          <div className="absolute top-3 left-1/2 -translate-x-1/2 w-[126px] h-[37px] bg-black rounded-full z-50" />
          
          {/* Header */}
          <div className="px-5 pt-16 pb-3">
            {/* Month & Navigation */}
            <div className="flex items-center justify-between mb-5">
              <div className="flex items-baseline gap-3">
                <h1 className="text-2xl font-semibold text-stone-800 tracking-tight" style={{ fontFamily: 'SF Pro Display, system-ui' }}>
                  January
                </h1>
                <span className="text-2xl font-light text-amber-600/80">2026</span>
                <svg className="w-4 h-4 text-stone-400 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                </svg>
              </div>
              <button className="w-9 h-9 rounded-full bg-white/80 shadow-sm flex items-center justify-center border border-stone-200/50">
                <svg className="w-4 h-4 text-stone-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 6v6l4 2m6-2a10 10 0 11-20 0 10 10 0 0120 0z" />
                </svg>
              </button>
            </div>

            {/* Week Header */}
            <div className="flex">
              {/* Spacer for time labels */}
              <div className="w-8" />
              {/* Days */}
              <div className="flex-1 flex justify-between px-1">
                {days.map((d, i) => (
                  <div key={i} className="flex flex-col items-center w-10">
                    <span className="text-[10px] font-medium text-stone-400 uppercase tracking-wider mb-1">
                      {d.day}
                    </span>
                    <div className={`w-8 h-8 rounded-full flex items-center justify-center transition-all ${
                      d.isToday 
                        ? 'bg-stone-800 text-white shadow-lg shadow-stone-800/20' 
                        : 'text-stone-700'
                    }`}>
                      <span className={`text-sm font-medium ${d.isToday ? 'text-white' : ''}`}>
                        {d.date}
                      </span>
                    </div>
                    {/* Task count indicator */}
                    <div className="flex gap-0.5 mt-1.5">
                      {weekSchedule[i].tasks.length > 3 && (
                        <span className="text-[9px] text-stone-400 font-medium">
                          {weekSchedule[i].tasks.length - 2}
                        </span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Streak/Stats Bar */}
          <div className="mx-5 mb-3 flex items-center gap-2">
            <div className="flex items-center gap-1.5 bg-white/60 backdrop-blur-sm rounded-full px-3 py-1.5 border border-stone-200/50">
              <span className="text-amber-500">🔥</span>
              <span className="text-xs font-semibold text-stone-700">20</span>
            </div>
            {days.map((d, i) => (
              <div 
                key={i}
                className={`flex-1 h-1.5 rounded-full ${
                  i < 5 ? 'bg-sage-400' : i === 5 ? 'bg-stone-300' : 'bg-stone-200'
                }`}
                style={{ backgroundColor: i < 5 ? colors.sage : i === 5 ? '#d1d5db' : '#e5e7eb' }}
              />
            ))}
          </div>

          {/* Timeline Grid */}
          <div className="flex-1 mx-3 relative overflow-hidden" style={{ height: `${timelineHeight}px` }}>
            {/* Time Labels */}
            <div className="absolute left-0 top-0 bottom-0 w-8 z-10">
              {hours.filter((_, i) => i % 3 === 0).map((hour) => (
                <div 
                  key={hour}
                  className="absolute text-[9px] font-medium text-stone-400 -translate-y-1/2"
                  style={{ top: getTaskPosition(hour) }}
                >
                  {hour.toString().padStart(2, '0')}
                </div>
              ))}
            </div>

            {/* Grid Lines */}
            <div className="absolute left-8 right-0 top-0 bottom-0">
              {hours.filter((_, i) => i % 3 === 0).map((hour) => (
                <div 
                  key={hour}
                  className="absolute left-0 right-0 border-t border-stone-200/50"
                  style={{ top: getTaskPosition(hour) }}
                />
              ))}
            </div>

            {/* Day Columns */}
            <div className="absolute left-8 right-0 top-0 bottom-0 flex">
              {weekSchedule.map((day, dayIndex) => (
                <div key={dayIndex} className="flex-1 relative px-0.5">
                  {/* Vertical track line */}
                  <div 
                    className={`absolute left-1/2 -translate-x-1/2 w-0.5 rounded-full ${
                      days[dayIndex].isToday ? 'bg-stone-300' : 'bg-stone-200/70'
                    }`}
                    style={{ 
                      top: getTaskPosition(day.tasks[0]?.time || 6),
                      bottom: timelineHeight - getTaskPosition((day.tasks[day.tasks.length - 1]?.time || 22) + 0.5)
                    }}
                  />
                  
                  {/* Tasks */}
                  {day.tasks.map((task, taskIndex) => {
                    const isSelected = selectedTask?.day === dayIndex && selectedTask?.id === task.id;
                    const isPast = days[dayIndex].isToday && task.time + task.duration < 11.5;
                    
                    return (
                      <div
                        key={taskIndex}
                        onClick={() => setSelectedTask({ day: dayIndex, id: task.id })}
                        className={`absolute left-1/2 -translate-x-1/2 cursor-pointer transition-all duration-300 ${
                          isSelected ? 'z-30 scale-110' : 'z-10'
                        }`}
                        style={{ top: getTaskPosition(task.time) }}
                      >
                        {/* Task Pin */}
                        <div 
                          className={`relative flex flex-col items-center transition-all duration-300`}
                        >
                          {/* Pin Head */}
                          <div 
                            className={`w-10 h-10 rounded-2xl flex items-center justify-center shadow-sm transition-all duration-300 ${
                              isSelected 
                                ? 'shadow-lg ring-2 ring-white' 
                                : isPast 
                                  ? 'opacity-50' 
                                  : ''
                            }`}
                            style={{ 
                              backgroundColor: task.color,
                              boxShadow: isSelected ? `0 8px 24px ${task.color}40` : undefined
                            }}
                          >
                            <span className="text-white text-base font-medium">{task.icon}</span>
                          </div>
                          
                          {/* Duration Line */}
                          {task.duration > 0.5 && (
                            <div 
                              className={`w-1 rounded-full mt-0.5 transition-opacity ${isPast ? 'opacity-30' : 'opacity-60'}`}
                              style={{ 
                                backgroundColor: task.color,
                                height: Math.max(getTaskHeight(task.duration) - 44, 4)
                              }}
                            />
                          )}
                        </div>
                      </div>
                    );
                  })}

                  {/* Current Time Indicator - only on today */}
                  {days[dayIndex].isToday && (
                    <div 
                      className="absolute left-0 right-0 flex items-center z-20"
                      style={{ top: currentTimePosition }}
                    >
                      <div className="flex-1 h-[2px] bg-gradient-to-r from-transparent via-rose-400 to-transparent" />
                    </div>
                  )}
                </div>
              ))}
            </div>

            {/* Current Time Dot */}
            <div 
              className="absolute left-6 w-3 h-3 bg-rose-400 rounded-full shadow-lg shadow-rose-400/40 z-30 -translate-x-1/2"
              style={{ top: currentTimePosition - 6 }}
            >
              <div className="absolute inset-0 bg-rose-400 rounded-full animate-ping opacity-30" />
            </div>
          </div>

          {/* Selected Task Card */}
          <div className="absolute bottom-20 left-4 right-4 z-40">
            {selectedTaskData && (
              <div 
                className="bg-white/95 backdrop-blur-xl rounded-3xl p-4 shadow-xl border border-white/50 transition-all duration-300"
                style={{ boxShadow: `0 8px 32px ${selectedTaskData.color}20` }}
              >
                <div className="flex items-center gap-4">
                  <div 
                    className="w-14 h-14 rounded-2xl flex items-center justify-center shadow-sm"
                    style={{ backgroundColor: selectedTaskData.color }}
                  >
                    <span className="text-white text-2xl">{selectedTaskData.icon}</span>
                  </div>
                  <div className="flex-1">
                    <p className="text-xs text-stone-500 font-medium mb-0.5">
                      {formatTime(selectedTaskData.time)} – {formatTime(selectedTaskData.time + selectedTaskData.duration)} ({selectedTaskData.duration * 60} min)
                    </p>
                    <h3 className="text-lg font-semibold text-stone-800">{selectedTaskData.label}</h3>
                  </div>
                  <div className="flex items-center gap-2">
                    <button 
                      className="w-10 h-10 rounded-full flex items-center justify-center transition-all"
                      style={{ backgroundColor: `${selectedTaskData.color}15` }}
                    >
                      <svg className="w-5 h-5" style={{ color: selectedTaskData.color }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    </button>
                    <button 
                      className="w-10 h-10 rounded-full border-2 flex items-center justify-center transition-all hover:bg-stone-50"
                      style={{ borderColor: selectedTaskData.color }}
                    >
                      <svg className="w-5 h-5 text-stone-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Bottom Navigation */}
          <div className="absolute bottom-0 left-0 right-0 bg-white/90 backdrop-blur-xl border-t border-stone-200/50">
            <div className="flex justify-around items-center py-2.5 pb-8">
              {[
                { icon: (
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
                  </svg>
                ), label: 'Inbox', active: false },
                { icon: (
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4 6h16M4 10h16M4 14h16M4 18h16" />
                  </svg>
                ), label: 'Timeline', active: true },
                { icon: (
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
                  </svg>
                ), label: 'AI', active: false },
                { icon: (
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                ), label: 'Settings', active: false },
              ].map((item, i) => (
                <button 
                  key={i} 
                  className={`flex flex-col items-center gap-1 px-5 py-1 rounded-xl transition-all ${
                    item.active ? 'text-stone-800' : 'text-stone-400'
                  }`}
                >
                  {item.icon}
                  <span className="text-[10px] font-medium tracking-wide">{item.label}</span>
                </button>
              ))}
            </div>
          </div>

          {/* FAB */}
          <button className="absolute bottom-24 right-4 w-14 h-14 bg-gradient-to-br from-stone-700 to-stone-900 rounded-full shadow-xl shadow-stone-900/30 flex items-center justify-center z-50 active:scale-95 transition-transform">
            <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
            </svg>
          </button>

          {/* Home Indicator */}
          <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-32 h-1 bg-stone-900 rounded-full" />
        </div>
      </div>

      {/* Design System Panel */}
      <div className="ml-12 max-w-md space-y-6">
        <div>
          <h2 className="text-2xl font-bold text-stone-800 mb-2">Weekly Timeline</h2>
          <p className="text-stone-500">Tiimo-inspired design with refined aesthetics</p>
        </div>
        
        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-4">Color Palette</h3>
          <div className="grid grid-cols-2 gap-3">
            {Object.entries(colors).map(([name, color]) => (
              <div key={name} className="flex items-center gap-3">
                <div 
                  className="w-10 h-10 rounded-xl shadow-sm"
                  style={{ backgroundColor: color }}
                />
                <div>
                  <p className="text-xs font-semibold text-stone-700 capitalize">{name}</p>
                  <p className="text-[10px] font-mono text-stone-400">{color}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Typography</h3>
          <div className="space-y-3">
            <div>
              <p className="text-2xl font-semibold text-stone-800">SF Pro Display</p>
              <p className="text-xs text-stone-400">Headers & Titles</p>
            </div>
            <div>
              <p className="text-sm font-medium text-stone-600">SF Pro Text Medium</p>
              <p className="text-xs text-stone-400">Body & Labels</p>
            </div>
            <div>
              <p className="text-xs font-mono text-stone-500">SF Mono</p>
              <p className="text-xs text-stone-400">Time & Numbers</p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Design Principles</h3>
          <ul className="space-y-2 text-sm text-stone-600">
            <li className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 bg-amber-500 rounded-full mt-1.5" />
              <span>Warm neutral base (stone) for reduced eye strain</span>
            </li>
            <li className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 bg-amber-500 rounded-full mt-1.5" />
              <span>Rounded squares (squircles) for iOS consistency</span>
            </li>
            <li className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 bg-amber-500 rounded-full mt-1.5" />
              <span>Subtle shadows with color tinting</span>
            </li>
            <li className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 bg-amber-500 rounded-full mt-1.5" />
              <span>Glassmorphism for layered elements</span>
            </li>
            <li className="flex items-start gap-2">
              <div className="w-1.5 h-1.5 bg-amber-500 rounded-full mt-1.5" />
              <span>Semantic colors (sage=wellness, sky=work)</span>
            </li>
          </ul>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Swift Implementation</h3>
          <div className="space-y-2 text-xs font-mono text-stone-600 bg-stone-50 rounded-xl p-3">
            <p className="text-stone-400">// Key components</p>
            <p>ScrollViewReader + LazyVStack</p>
            <p>GeometryReader for positioning</p>
            <p>Canvas for timeline drawing</p>
            <p>withAnimation(.spring())</p>
            <p>.sensoryFeedback(.impact)</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default WeeklyTimelineView;
