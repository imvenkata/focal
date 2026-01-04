import React, { useState } from 'react';

const UnifiedPlannerView = () => {
  const [viewMode, setViewMode] = useState('week'); // 'week' or 'day'
  const [selectedDay, setSelectedDay] = useState(5); // Saturday
  const [completedTasks, setCompletedTasks] = useState(['rise']);
  
  const days = [
    { day: 'Mon', date: 29, month: 'Dec' },
    { day: 'Tue', date: 30, month: 'Dec' },
    { day: 'Wed', date: 31, month: 'Dec' },
    { day: 'Thu', date: 1, month: 'Jan' },
    { day: 'Fri', date: 2, month: 'Jan' },
    { day: 'Sat', date: 3, month: 'Jan', isToday: true },
    { day: 'Sun', date: 4, month: 'Jan' },
  ];

  const colors = {
    coral: '#E8847C',
    sage: '#7BAE7F',
    sky: '#6BA3D6',
    lavender: '#9B8EC2',
    amber: '#D4A853',
    rose: '#C97B8E',
    night: '#5C6B7A',
  };

  // Weekly schedule data
  const weekSchedule = [
    { tasks: [
      { id: 'workout', time: 5, duration: 1, color: colors.coral, icon: '◎' },
      { id: 'wake', time: 6.5, duration: 0.5, color: colors.coral, icon: '☀️' },
      { id: 'work', time: 9, duration: 4, color: colors.sky, icon: '💻' },
      { id: 'sleep', time: 22, duration: 1, color: colors.night, icon: '🌙' },
    ]},
    { tasks: [
      { id: 'wake', time: 6.5, duration: 0.5, color: colors.coral, icon: '☀️' },
      { id: 'work', time: 9, duration: 4, color: colors.sky, icon: '💻' },
      { id: 'sleep', time: 22, duration: 1, color: colors.night, icon: '🌙' },
    ]},
    { tasks: [
      { id: 'wake', time: 6.5, duration: 0.5, color: colors.coral, icon: '☀️' },
      { id: 'yoga', time: 7, duration: 1, color: colors.sage, icon: '🧘' },
      { id: 'work', time: 9, duration: 4, color: colors.sky, icon: '💻' },
      { id: 'sleep', time: 22, duration: 1, color: colors.night, icon: '🌙' },
    ]},
    { tasks: [
      { id: 'wake', time: 6.5, duration: 0.5, color: colors.coral, icon: '☀️' },
      { id: 'work', time: 9, duration: 4, color: colors.sky, icon: '💻' },
      { id: 'gym', time: 17, duration: 1.5, color: colors.sage, icon: '🏋️' },
      { id: 'sleep', time: 22, duration: 1, color: colors.night, icon: '🌙' },
    ]},
    { tasks: [
      { id: 'wake', time: 6.5, duration: 0.5, color: colors.coral, icon: '☀️' },
      { id: 'work', time: 9, duration: 3, color: colors.sky, icon: '💻' },
      { id: 'social', time: 18, duration: 3, color: colors.rose, icon: '🎉' },
      { id: 'sleep', time: 23, duration: 1, color: colors.night, icon: '🌙' },
    ]},
    { tasks: [
      { id: 'rise', time: 6, duration: 0.5, color: colors.coral, icon: '☀️', title: 'Rise and Shine' },
      { id: 'gym', time: 12, duration: 1, color: colors.sage, icon: '🏋️', title: 'Gym' },
      { id: 'wind', time: 22, duration: 0.5, color: colors.night, icon: '🌙', title: 'Wind Down' },
    ]},
    { tasks: [
      { id: 'wake', time: 8, duration: 0.5, color: colors.coral, icon: '☀️' },
      { id: 'brunch', time: 10, duration: 1.5, color: colors.amber, icon: '🍳' },
      { id: 'relax', time: 14, duration: 3, color: colors.lavender, icon: '📚' },
      { id: 'sleep', time: 22, duration: 1, color: colors.night, icon: '🌙' },
    ]},
  ];

  const dayTasks = weekSchedule[selectedDay].tasks;
  
  const handleDayTap = (index) => {
    if (viewMode === 'week') {
      setSelectedDay(index);
      setViewMode('day');
    } else {
      setSelectedDay(index);
    }
  };

  const timelineHeight = 420;
  const getTaskPosition = (time) => ((time - 5) / (23 - 5)) * timelineHeight;
  const getTaskHeight = (duration) => (duration / (23 - 5)) * timelineHeight;
  const currentTimePosition = getTaskPosition(11.5);

  const toggleComplete = (taskId) => {
    setCompletedTasks(prev => 
      prev.includes(taskId) ? prev.filter(id => id !== taskId) : [...prev, taskId]
    );
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-stone-100 via-stone-50 to-amber-50/20 p-8">
      {/* iPhone Frame */}
      <div className="relative w-[390px] h-[844px] bg-stone-900 rounded-[55px] p-3 shadow-2xl">
        <div className="relative w-full h-full bg-[#F8F7F4] rounded-[45px] overflow-hidden flex flex-col">
          
          {/* Dynamic Island */}
          <div className="absolute top-3 left-1/2 -translate-x-1/2 w-[126px] h-[37px] bg-black rounded-full z-50" />
          
          {/* Header */}
          <div className="px-5 pt-16 pb-3">
            {/* Title Row with View Toggle */}
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-baseline gap-2">
                <h1 className="text-2xl font-semibold text-stone-800 tracking-tight">
                  {viewMode === 'day' ? `${days[selectedDay].date} January` : 'January'}
                </h1>
                <span className="text-2xl font-light text-amber-600/80">2026</span>
                <svg className="w-4 h-4 text-stone-400 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                </svg>
              </div>

              {/* View Mode Toggle */}
              <div className="flex items-center bg-stone-100 rounded-xl p-1">
                <button
                  onClick={() => setViewMode('week')}
                  className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
                    viewMode === 'week' 
                      ? 'bg-white text-stone-800 shadow-sm' 
                      : 'text-stone-500 hover:text-stone-700'
                  }`}
                >
                  Week
                </button>
                <button
                  onClick={() => setViewMode('day')}
                  className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
                    viewMode === 'day' 
                      ? 'bg-white text-stone-800 shadow-sm' 
                      : 'text-stone-500 hover:text-stone-700'
                  }`}
                >
                  Day
                </button>
              </div>
            </div>

            {/* Week Selector */}
            <div className="flex justify-between">
              {days.map((d, i) => (
                <button
                  key={i}
                  onClick={() => handleDayTap(i)}
                  className={`flex flex-col items-center transition-all duration-300 ${
                    viewMode === 'day' && selectedDay !== i ? 'opacity-40 scale-90' : ''
                  }`}
                >
                  <span className="text-[10px] font-medium text-stone-400 uppercase tracking-wider mb-1">
                    {d.day}
                  </span>
                  <div className={`w-9 h-9 rounded-full flex items-center justify-center transition-all mb-2 ${
                    selectedDay === i 
                      ? 'bg-stone-800 text-white shadow-lg shadow-stone-800/25' 
                      : d.isToday 
                        ? 'bg-amber-100 text-amber-700'
                        : 'text-stone-700 hover:bg-stone-100'
                  }`}>
                    <span className="text-sm font-semibold">{d.date}</span>
                  </div>
                  {/* Task indicators */}
                  <div className="flex gap-0.5">
                    {weekSchedule[i].tasks.slice(0, 3).map((task, ti) => (
                      <div 
                        key={ti}
                        className="w-2 h-2 rounded-full transition-all"
                        style={{ backgroundColor: task.color }}
                      />
                    ))}
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Content Area */}
          <div className="flex-1 overflow-hidden">
            {/* WEEK VIEW */}
            {viewMode === 'week' && (
              <div className="h-full px-3 pb-24 animate-fadeIn">
                {/* Mini stats */}
                <div className="flex items-center gap-2 px-2 mb-3">
                  <div className="flex items-center gap-1.5 bg-white/60 rounded-full px-3 py-1.5 border border-stone-200/50">
                    <span className="text-amber-500">🔥</span>
                    <span className="text-xs font-semibold text-stone-700">20</span>
                  </div>
                  <div className="flex-1 h-1.5 bg-stone-200 rounded-full overflow-hidden">
                    <div className="h-full bg-gradient-to-r from-emerald-400 to-teal-500 rounded-full" style={{ width: '60%' }} />
                  </div>
                  <span className="text-[10px] font-medium text-stone-500">12/20</span>
                </div>

                {/* Timeline Grid */}
                <div className="relative" style={{ height: `${timelineHeight}px` }}>
                  {/* Time Labels */}
                  <div className="absolute left-0 top-0 bottom-0 w-8 z-10">
                    {[6, 9, 12, 15, 18, 21].map((hour) => (
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
                    {[6, 9, 12, 15, 18, 21].map((hour) => (
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
                        {/* Vertical track */}
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
                        {day.tasks.map((task, taskIndex) => (
                          <div
                            key={taskIndex}
                            onClick={() => handleDayTap(dayIndex)}
                            className="absolute left-1/2 -translate-x-1/2 cursor-pointer transition-all duration-300 hover:scale-110 z-10"
                            style={{ top: getTaskPosition(task.time) }}
                          >
                            <div 
                              className="w-9 h-9 rounded-xl flex items-center justify-center shadow-sm"
                              style={{ backgroundColor: task.color }}
                            >
                              <span className="text-white text-sm">{task.icon}</span>
                            </div>
                            {task.duration > 0.5 && (
                              <div 
                                className="w-1 mx-auto rounded-full mt-0.5 opacity-60"
                                style={{ 
                                  backgroundColor: task.color,
                                  height: Math.max(getTaskHeight(task.duration) - 40, 4)
                                }}
                              />
                            )}
                          </div>
                        ))}

                        {/* Current Time - only on today */}
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

                {/* Tap hint */}
                <p className="text-center text-xs text-stone-400 mt-4">
                  Tap a day to see details
                </p>
              </div>
            )}

            {/* DAY VIEW */}
            {viewMode === 'day' && (
              <div className="h-full bg-white rounded-t-[32px] shadow-[0_-4px_24px_rgba(0,0,0,0.06)] flex flex-col animate-slideUp">
                {/* Handle */}
                <div className="flex justify-center pt-3 pb-2">
                  <div className="w-10 h-1 bg-stone-300 rounded-full" />
                </div>

                {/* Energy + Stats */}
                <div className="px-5 pb-4 flex items-center gap-3">
                  <div className="flex items-center gap-2 bg-stone-50 rounded-2xl px-4 py-2.5">
                    <div className="relative w-10 h-10">
                      <svg className="w-10 h-10 -rotate-90">
                        <circle cx="20" cy="20" r="16" fill="none" stroke="#E5E5E5" strokeWidth="4" />
                        <circle cx="20" cy="20" r="16" fill="none" stroke={colors.coral} strokeWidth="4" strokeLinecap="round" strokeDasharray="20 100" />
                      </svg>
                      <span className="absolute inset-0 flex items-center justify-center text-base">🔥</span>
                    </div>
                    <div>
                      <div className="flex items-baseline gap-1">
                        <span className="text-lg font-bold text-stone-800">20</span>
                        <span className="text-xs text-stone-400">/ 100</span>
                      </div>
                      <span className="text-[10px] font-medium text-stone-500 uppercase tracking-wide">Energy</span>
                    </div>
                  </div>
                  <div className="flex-1 flex gap-2">
                    <div className="flex-1 bg-stone-50 rounded-2xl px-3 py-2.5 text-center">
                      <span className="text-lg font-bold text-stone-800">{dayTasks.length}</span>
                      <p className="text-[10px] text-stone-500 font-medium">Tasks</p>
                    </div>
                    <div className="flex-1 bg-stone-50 rounded-2xl px-3 py-2.5 text-center">
                      <span className="text-lg font-bold text-emerald-600">{completedTasks.length}</span>
                      <p className="text-[10px] text-stone-500 font-medium">Done</p>
                    </div>
                  </div>
                </div>

                {/* Timeline */}
                <div className="flex-1 overflow-y-auto px-5 pb-32">
                  <div className="relative ml-14">
                    {/* Vertical dashed line */}
                    <div className="absolute left-6 top-4 bottom-4 w-0.5 border-l-2 border-dashed border-stone-200" />

                    {dayTasks.map((task, index) => (
                      <div key={task.id} className="relative pb-8">
                        {/* Time label */}
                        <span className="absolute -left-14 top-4 text-xs font-medium text-stone-400 w-10 text-right">
                          {Math.floor(task.time).toString().padStart(2, '0')}:00
                        </span>
                        
                        <div className="flex items-start gap-4">
                          {/* Task Pill */}
                          <div 
                            className="w-14 rounded-2xl flex items-center justify-center shadow-sm relative z-10"
                            style={{ 
                              backgroundColor: task.color,
                              height: task.duration > 0.5 ? `${Math.max(56, task.duration * 60)}px` : '56px',
                              paddingTop: task.duration > 0.5 ? '12px' : '0',
                              paddingBottom: task.duration > 0.5 ? '12px' : '0',
                            }}
                          >
                            <span className="text-2xl">{task.icon}</span>
                          </div>
                          
                          {/* Task Content */}
                          <div className="flex-1 pt-2">
                            <div className="flex items-center gap-2 mb-1">
                              <span className="text-xs text-stone-400 font-medium">
                                {Math.floor(task.time).toString().padStart(2, '0')}:00
                                {task.duration > 0.5 && ` – ${Math.floor(task.time + task.duration).toString().padStart(2, '0')}:00`}
                              </span>
                              {task.duration > 0.5 && (
                                <span className="text-[10px] px-1.5 py-0.5 bg-stone-100 rounded text-stone-500 font-medium">
                                  {task.duration}hr
                                </span>
                              )}
                            </div>
                            <h3 className="text-base font-semibold text-stone-800">
                              {task.title || task.id.charAt(0).toUpperCase() + task.id.slice(1)}
                            </h3>
                          </div>

                          {/* Checkbox */}
                          <button 
                            onClick={() => toggleComplete(task.id)}
                            className={`w-7 h-7 rounded-full border-2 flex items-center justify-center transition-all mt-3 ${
                              completedTasks.includes(task.id)
                                ? 'border-emerald-500 bg-emerald-500'
                                : ''
                            }`}
                            style={{ borderColor: completedTasks.includes(task.id) ? undefined : task.color }}
                          >
                            {completedTasks.includes(task.id) && (
                              <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                              </svg>
                            )}
                          </button>
                        </div>

                        {/* Empty interval message */}
                        {index < dayTasks.length - 1 && (dayTasks[index + 1].time - (task.time + task.duration)) > 2 && (
                          <div className="ml-[72px] mt-6 flex items-center gap-2 text-stone-400">
                            <span className="text-sm">💤</span>
                            <span className="text-sm italic">A well-spent interval.</span>
                          </div>
                        )}
                      </div>
                    ))}

                    {/* Add Task */}
                    <div className="ml-[72px] pt-4">
                      <button className="flex items-center gap-2 px-4 py-2.5 bg-stone-50 hover:bg-stone-100 rounded-xl transition-colors group">
                        <div className="w-6 h-6 rounded-full bg-amber-500 flex items-center justify-center group-hover:scale-110 transition-transform">
                          <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 4v16m8-8H4" />
                          </svg>
                        </div>
                        <span className="text-sm font-semibold text-amber-600">Add Task</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>

          {/* Bottom Navigation */}
          <div className="absolute bottom-0 left-0 right-0 bg-white/95 backdrop-blur-xl border-t border-stone-100">
            <div className="flex justify-around items-center py-2.5 pb-8">
              {[
                { label: 'Inbox', active: false, icon: 'inbox' },
                { label: 'Timeline', active: true, icon: 'timeline' },
                { label: 'AI', active: false, icon: 'ai' },
                { label: 'Settings', active: false, icon: 'settings' },
              ].map((item, i) => (
                <button 
                  key={i} 
                  className={`flex flex-col items-center gap-1 px-5 py-1 rounded-xl transition-all ${
                    item.active ? 'text-stone-800' : 'text-stone-400'
                  }`}
                >
                  {item.icon === 'inbox' && (
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
                    </svg>
                  )}
                  {item.icon === 'timeline' && (
                    <svg className="w-6 h-6" fill={item.active ? "currentColor" : "none"} stroke="currentColor" viewBox="0 0 24 24">
                      <circle cx="6" cy="6" r="2.5" strokeWidth={item.active ? 0 : 1.5} />
                      <rect x="4.5" y="8" width="3" height="12" rx="1.5" strokeWidth={item.active ? 0 : 1.5} />
                      <circle cx="18" cy="10" r="2.5" strokeWidth={item.active ? 0 : 1.5} />
                      <rect x="16.5" y="12" width="3" height="8" rx="1.5" strokeWidth={item.active ? 0 : 1.5} />
                    </svg>
                  )}
                  {item.icon === 'ai' && (
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
                    </svg>
                  )}
                  {item.icon === 'settings' && (
                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                  )}
                  <span className="text-[10px] font-medium tracking-wide">{item.label}</span>
                </button>
              ))}
            </div>
          </div>

          {/* FAB */}
          <button className="absolute bottom-24 right-5 w-14 h-14 bg-gradient-to-br from-stone-700 to-stone-900 rounded-full shadow-xl shadow-stone-900/30 flex items-center justify-center z-50 active:scale-95 transition-transform">
            <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
            </svg>
          </button>

          {/* Home Indicator */}
          <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-32 h-1 bg-stone-900 rounded-full" />
        </div>
      </div>

      {/* Navigation Guide */}
      <div className="ml-12 max-w-md space-y-5">
        <div>
          <h2 className="text-2xl font-bold text-stone-800 mb-2">View Navigation</h2>
          <p className="text-stone-500">Seamless switching between week and day</p>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-4">Navigation Methods</h3>
          <div className="space-y-4">
            <div className="flex items-start gap-3">
              <div className="w-10 h-6 bg-stone-100 rounded-lg flex items-center p-0.5 flex-shrink-0">
                <div className="w-4 h-5 bg-white rounded shadow-sm" />
              </div>
              <div>
                <p className="font-medium text-stone-700 text-sm">Segmented Control</p>
                <p className="text-xs text-stone-500">Toggle between Week/Day in header</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 bg-stone-800 rounded-full flex items-center justify-center flex-shrink-0">
                <span className="text-white text-xs font-bold">3</span>
              </div>
              <div>
                <p className="font-medium text-stone-700 text-sm">Tap Day Circle</p>
                <p className="text-xs text-stone-500">Tapping a day auto-switches to Day view</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 bg-stone-100 rounded-lg flex items-center justify-center flex-shrink-0">
                <svg className="w-5 h-5 text-stone-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </div>
              <div>
                <p className="font-medium text-stone-700 text-sm">Swipe Down (Optional)</p>
                <p className="text-xs text-stone-500">Pull down on Day view to collapse</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 bg-stone-100 rounded-lg flex items-center justify-center flex-shrink-0">
                <span className="text-lg">🤏</span>
              </div>
              <div>
                <p className="font-medium text-stone-700 text-sm">Pinch Gesture (Optional)</p>
                <p className="text-xs text-stone-500">Pinch out for week, pinch in for day</p>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Swift Implementation</h3>
          <div className="text-xs font-mono text-stone-600 bg-stone-50 rounded-xl p-3 space-y-1">
            <p className="text-stone-400">// View state</p>
            <p>@State var viewMode: ViewMode = .week</p>
            <p>@State var selectedDay: Int = 5</p>
            <p></p>
            <p className="text-stone-400">// Animated transition</p>
            <p>withAnimation(.spring(</p>
            <p className="pl-3">response: 0.4,</p>
            <p className="pl-3">dampingFraction: 0.8</p>
            <p>)) {'{'}</p>
            <p className="pl-3">viewMode = .day</p>
            <p>{'}'}</p>
            <p></p>
            <p className="text-stone-400">// Gesture support</p>
            <p>.gesture(</p>
            <p className="pl-3">MagnificationGesture()</p>
            <p className="pl-3">.onEnded {'{'} scale in</p>
            <p className="pl-6">viewMode = scale {'>'} 1 ? .week : .day</p>
            <p className="pl-3">{'}'}</p>
            <p>)</p>
          </div>
        </div>

        <div className="bg-gradient-to-br from-amber-50 to-orange-50 rounded-2xl p-5 border border-amber-200/50">
          <h3 className="font-semibold text-amber-800 mb-2">💡 Pro Tip</h3>
          <p className="text-sm text-amber-700">
            Use <code className="bg-amber-100 px-1.5 py-0.5 rounded text-xs">matchedGeometryEffect</code> in SwiftUI to animate the selected day circle as it transitions between week and day views.
          </p>
        </div>
      </div>

      <style jsx>{`
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes slideUp {
          from { transform: translateY(20px); opacity: 0; }
          to { transform: translateY(0); opacity: 1; }
        }
        .animate-fadeIn {
          animation: fadeIn 0.3s ease-out;
        }
        .animate-slideUp {
          animation: slideUp 0.4s ease-out;
        }
      `}</style>
    </div>
  );
};

export default UnifiedPlannerView;
