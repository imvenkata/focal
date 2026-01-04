import React, { useState } from 'react';

const DailyDetailView = () => {
  const [selectedDay, setSelectedDay] = useState(5); // Saturday selected
  const [completedTasks, setCompletedTasks] = useState(['rise']);
  
  const days = [
    { day: 'Mon', date: 29, tasks: [{ color: '#E8847C' }, { color: '#6BA3D6' }, { color: '#4A5568' }] },
    { day: 'Tue', date: 30, tasks: [{ color: '#E8847C' }, { color: '#6BA3D6' }] },
    { day: 'Wed', date: 31, tasks: [{ color: '#E8847C' }, { color: '#7BAE7F' }, { color: '#4A5568' }] },
    { day: 'Thu', date: 1, tasks: [{ color: '#E8847C' }, { color: '#6BA3D6' }] },
    { day: 'Fri', date: 2, tasks: [{ color: '#E8847C' }, { color: '#C97B8E' }] },
    { day: 'Sat', date: 3, tasks: [{ color: '#E8847C' }, { color: '#7BAE7F' }, { color: '#4A5568' }], isToday: true },
    { day: 'Sun', date: 4, tasks: [{ color: '#D4A853' }, { color: '#9B8EC2' }] },
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

  const tasks = [
    { 
      id: 'rise', 
      time: '06:00', 
      endTime: null,
      title: 'Rise and Shine', 
      icon: '☀️',
      color: colors.coral,
      isRoutine: true,
      duration: null
    },
    { 
      id: 'gym', 
      time: '12:00', 
      endTime: '13:00',
      title: 'Gym', 
      icon: '🏋️',
      color: colors.sage,
      isRoutine: false,
      duration: '1 hr'
    },
    { 
      id: 'wind', 
      time: '22:00', 
      endTime: null,
      title: 'Wind Down', 
      icon: '🌙',
      color: colors.night,
      isRoutine: true,
      duration: null
    },
  ];

  const timeSlots = ['06:00', '09:00', '12:00', '13:00', '16:00', '17:32', '19:00', '22:00'];
  const currentTime = '17:32';
  const energyLevel = 20;

  const toggleComplete = (taskId) => {
    setCompletedTasks(prev => 
      prev.includes(taskId) 
        ? prev.filter(id => id !== taskId)
        : [...prev, taskId]
    );
  };

  const getTimeUntilNext = () => {
    return '4h 28m';
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-stone-100 via-stone-50 to-amber-50/20 p-8">
      {/* iPhone Frame */}
      <div className="relative w-[390px] h-[844px] bg-stone-900 rounded-[55px] p-3 shadow-2xl">
        {/* Screen */}
        <div className="relative w-full h-full bg-[#F8F7F4] rounded-[45px] overflow-hidden flex flex-col">
          
          {/* Dynamic Island */}
          <div className="absolute top-3 left-1/2 -translate-x-1/2 w-[126px] h-[37px] bg-black rounded-full z-50" />
          
          {/* Header Section */}
          <div className="px-5 pt-16 pb-4 bg-[#F8F7F4]">
            {/* Date Header */}
            <div className="flex items-baseline gap-2 mb-5">
              <h1 className="text-2xl font-semibold text-stone-800 tracking-tight">
                3 January
              </h1>
              <span className="text-2xl font-light text-amber-600/80">2026</span>
              <svg className="w-4 h-4 text-stone-400 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
              </svg>
            </div>

            {/* Week Selector */}
            <div className="flex justify-between">
              {days.map((d, i) => (
                <button
                  key={i}
                  onClick={() => setSelectedDay(i)}
                  className="flex flex-col items-center"
                >
                  <span className="text-[10px] font-medium text-stone-400 uppercase tracking-wider mb-1">
                    {d.day}
                  </span>
                  <div className={`w-9 h-9 rounded-full flex items-center justify-center transition-all mb-2 ${
                    selectedDay === i 
                      ? 'bg-stone-800 text-white shadow-lg shadow-stone-800/25' 
                      : 'text-stone-700 hover:bg-stone-100'
                  }`}>
                    <span className="text-sm font-semibold">{d.date}</span>
                  </div>
                  {/* Task indicators */}
                  <div className="flex gap-0.5">
                    {d.tasks.slice(0, 3).map((task, ti) => (
                      <div 
                        key={ti}
                        className="w-2 h-2 rounded-full"
                        style={{ backgroundColor: task.color }}
                      />
                    ))}
                  </div>
                </button>
              ))}
            </div>
          </div>

          {/* Timeline Panel - Slide up sheet style */}
          <div className="flex-1 bg-white rounded-t-[32px] shadow-[0_-4px_24px_rgba(0,0,0,0.06)] overflow-hidden flex flex-col">
            {/* Handle */}
            <div className="flex justify-center pt-3 pb-2">
              <div className="w-10 h-1 bg-stone-300 rounded-full" />
            </div>

            {/* Energy Level */}
            <div className="px-5 pb-4 flex items-center gap-3">
              <div className="flex items-center gap-2 bg-stone-50 rounded-2xl px-4 py-2.5">
                <div className="relative w-10 h-10">
                  {/* Circular progress */}
                  <svg className="w-10 h-10 -rotate-90">
                    <circle
                      cx="20"
                      cy="20"
                      r="16"
                      fill="none"
                      stroke="#E5E5E5"
                      strokeWidth="4"
                    />
                    <circle
                      cx="20"
                      cy="20"
                      r="16"
                      fill="none"
                      stroke={colors.coral}
                      strokeWidth="4"
                      strokeLinecap="round"
                      strokeDasharray={`${(energyLevel / 100) * 100} 100`}
                    />
                  </svg>
                  <span className="absolute inset-0 flex items-center justify-center text-base">
                    🔥
                  </span>
                </div>
                <div>
                  <div className="flex items-baseline gap-1">
                    <span className="text-lg font-bold text-stone-800">{energyLevel}</span>
                    <span className="text-xs text-stone-400">/ 100</span>
                  </div>
                  <span className="text-[10px] font-medium text-stone-500 uppercase tracking-wide">Energy</span>
                </div>
              </div>

              {/* Quick stats */}
              <div className="flex-1 flex gap-2">
                <div className="flex-1 bg-stone-50 rounded-2xl px-3 py-2.5 text-center">
                  <span className="text-lg font-bold text-stone-800">3</span>
                  <p className="text-[10px] text-stone-500 font-medium">Tasks</p>
                </div>
                <div className="flex-1 bg-stone-50 rounded-2xl px-3 py-2.5 text-center">
                  <span className="text-lg font-bold text-emerald-600">1</span>
                  <p className="text-[10px] text-stone-500 font-medium">Done</p>
                </div>
              </div>
            </div>

            {/* Timeline */}
            <div className="flex-1 overflow-y-auto px-5 pb-32">
              <div className="relative">
                {/* Time column */}
                <div className="absolute left-0 top-0 bottom-0 w-12">
                  {/* Time labels positioned along the timeline */}
                </div>

                {/* Tasks timeline */}
                <div className="ml-14 relative">
                  {/* Vertical dashed line */}
                  <div className="absolute left-6 top-4 bottom-4 w-0.5 border-l-2 border-dashed border-stone-200" />

                  {/* Morning Task */}
                  <div className="relative pb-6">
                    <span className="absolute -left-14 top-3 text-xs font-medium text-stone-400 w-10 text-right">06:00</span>
                    
                    <div className="flex items-start gap-4">
                      {/* Task Pill */}
                      <div 
                        className="w-14 h-14 rounded-2xl flex items-center justify-center shadow-sm relative z-10"
                        style={{ backgroundColor: colors.coral }}
                      >
                        <span className="text-2xl">{tasks[0].icon}</span>
                      </div>
                      
                      {/* Task Content */}
                      <div className="flex-1 pt-1">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-xs text-stone-400 font-medium">06:00</span>
                          <span className="text-xs text-stone-300">↻</span>
                        </div>
                        <h3 className="text-base font-semibold text-stone-800">{tasks[0].title}</h3>
                      </div>

                      {/* Checkbox */}
                      <button 
                        onClick={() => toggleComplete('rise')}
                        className={`w-7 h-7 rounded-full border-2 flex items-center justify-center transition-all mt-3 ${
                          completedTasks.includes('rise')
                            ? 'border-emerald-500 bg-emerald-500'
                            : 'border-stone-300 hover:border-stone-400'
                        }`}
                      >
                        {completedTasks.includes('rise') && (
                          <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                          </svg>
                        )}
                      </button>
                    </div>
                  </div>

                  {/* Empty Interval */}
                  <div className="relative py-8">
                    <span className="absolute -left-14 top-1/2 -translate-y-1/2 text-xs font-medium text-stone-400 w-10 text-right">09:00</span>
                    
                    <div className="ml-[72px] flex items-center gap-2 text-stone-400">
                      <span className="text-sm">💤</span>
                      <span className="text-sm italic">A well-spent interval.</span>
                    </div>
                  </div>

                  {/* Gym Task */}
                  <div className="relative pb-6">
                    <span className="absolute -left-14 top-3 text-xs font-medium text-stone-400 w-10 text-right">12:00</span>
                    
                    <div className="flex items-start gap-4">
                      {/* Task Pill - Elongated for duration */}
                      <div 
                        className="w-14 rounded-2xl flex flex-col items-center justify-center shadow-sm relative z-10 py-4"
                        style={{ backgroundColor: colors.sage, minHeight: '100px' }}
                      >
                        <span className="text-2xl">{tasks[1].icon}</span>
                      </div>
                      
                      {/* Task Content */}
                      <div className="flex-1 pt-1">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-xs text-stone-400 font-medium">12:00 – 13:00</span>
                          <span className="text-[10px] px-1.5 py-0.5 bg-stone-100 rounded text-stone-500 font-medium">1 hr</span>
                        </div>
                        <h3 className="text-base font-semibold text-stone-800">{tasks[1].title}</h3>
                      </div>

                      {/* Checkbox */}
                      <button 
                        onClick={() => toggleComplete('gym')}
                        className={`w-7 h-7 rounded-full border-2 flex items-center justify-center transition-all mt-3 ${
                          completedTasks.includes('gym')
                            ? 'border-emerald-500 bg-emerald-500'
                            : 'border-sage-400'
                        }`}
                        style={{ borderColor: completedTasks.includes('gym') ? undefined : colors.sage }}
                      >
                        {completedTasks.includes('gym') && (
                          <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                          </svg>
                        )}
                      </button>
                    </div>

                    {/* End time label */}
                    <span className="absolute -left-14 bottom-0 text-xs font-medium text-stone-300 w-10 text-right">13:00</span>
                  </div>

                  {/* Current Time Indicator */}
                  <div className="relative py-4">
                    <div className="absolute -left-14 top-1/2 -translate-y-1/2 flex items-center">
                      <span className="text-xs font-bold text-rose-500 w-10 text-right">{currentTime}</span>
                    </div>
                    
                    {/* Current time line */}
                    <div className="flex items-center gap-2">
                      <div className="w-3 h-3 bg-rose-500 rounded-full shadow-lg shadow-rose-500/30 relative z-10">
                        <div className="absolute inset-0 bg-rose-500 rounded-full animate-ping opacity-40" />
                      </div>
                      <div className="flex-1 h-0.5 bg-gradient-to-r from-rose-500 to-transparent rounded-full" />
                    </div>
                  </div>

                  {/* Available Time Slot */}
                  <div className="relative py-6">
                    <span className="absolute -left-14 top-4 text-xs font-medium text-stone-400 w-10 text-right">16:00</span>
                    
                    <div className="ml-[72px]">
                      <div className="flex items-center gap-2 text-stone-500 mb-3">
                        <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <span className="text-sm">
                          Use <span className="font-semibold text-amber-600">{getTimeUntilNext()}</span>, task approaching.
                        </span>
                      </div>
                      
                      {/* Add Task Button */}
                      <button className="flex items-center gap-2 px-4 py-2.5 bg-stone-50 hover:bg-stone-100 rounded-xl transition-colors group">
                        <div className="w-6 h-6 rounded-full bg-amber-500 flex items-center justify-center group-hover:scale-110 transition-transform">
                          <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M12 4v16m8-8H4" />
                          </svg>
                        </div>
                        <span className="text-sm font-semibold text-amber-600">Add Task</span>
                      </button>
                    </div>

                    <span className="absolute -left-14 bottom-0 text-xs font-medium text-stone-300 w-10 text-right">19:00</span>
                  </div>

                  {/* Wind Down Task */}
                  <div className="relative pt-6">
                    <span className="absolute -left-14 top-9 text-xs font-medium text-stone-400 w-10 text-right">22:00</span>
                    
                    <div className="flex items-start gap-4">
                      {/* Task Pill */}
                      <div 
                        className="w-14 h-14 rounded-2xl flex items-center justify-center shadow-sm relative z-10"
                        style={{ backgroundColor: colors.night }}
                      >
                        <span className="text-2xl">{tasks[2].icon}</span>
                      </div>
                      
                      {/* Task Content */}
                      <div className="flex-1 pt-1">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-xs text-stone-400 font-medium">22:00</span>
                          <span className="text-xs text-stone-300">↻</span>
                        </div>
                        <h3 className="text-base font-semibold text-stone-800">{tasks[2].title}</h3>
                      </div>

                      {/* Checkbox */}
                      <button 
                        onClick={() => toggleComplete('wind')}
                        className={`w-7 h-7 rounded-full border-2 flex items-center justify-center transition-all mt-3 ${
                          completedTasks.includes('wind')
                            ? 'border-emerald-500 bg-emerald-500'
                            : ''
                        }`}
                        style={{ borderColor: completedTasks.includes('wind') ? undefined : colors.night }}
                      >
                        {completedTasks.includes('wind') && (
                          <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                          </svg>
                        )}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Bottom Navigation */}
          <div className="absolute bottom-0 left-0 right-0 bg-white/95 backdrop-blur-xl border-t border-stone-100">
            <div className="flex justify-around items-center py-2.5 pb-8">
              {[
                { icon: (
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
                  </svg>
                ), label: 'Inbox', active: false },
                { icon: (
                  <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                    <circle cx="6" cy="6" r="2.5" />
                    <rect x="4.5" y="8" width="3" height="12" rx="1.5" />
                    <circle cx="18" cy="10" r="2.5" />
                    <rect x="16.5" y="12" width="3" height="8" rx="1.5" />
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
          <button className="absolute bottom-24 right-5 w-14 h-14 bg-gradient-to-br from-stone-700 to-stone-900 rounded-full shadow-xl shadow-stone-900/30 flex items-center justify-center z-50 active:scale-95 transition-transform">
            <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
            </svg>
          </button>

          {/* Home Indicator */}
          <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-32 h-1 bg-stone-900 rounded-full" />
        </div>
      </div>

      {/* Design Specs */}
      <div className="ml-12 max-w-md space-y-5">
        <div>
          <h2 className="text-2xl font-bold text-stone-800 mb-2">Daily Detail View</h2>
          <p className="text-stone-500">Vertical timeline with task pills</p>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Component Anatomy</h3>
          <div className="space-y-3">
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-lg bg-coral-100 flex items-center justify-center text-sm" style={{ backgroundColor: '#E8847C20' }}>📍</div>
              <div>
                <p className="font-medium text-stone-700 text-sm">Task Pill</p>
                <p className="text-xs text-stone-500">56×56pt default, extends for duration</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-lg bg-stone-100 flex items-center justify-center text-sm">⏱️</div>
              <div>
                <p className="font-medium text-stone-700 text-sm">Time Labels</p>
                <p className="text-xs text-stone-500">SF Mono 11pt, stone-400</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-lg bg-rose-100 flex items-center justify-center text-sm">🔴</div>
              <div>
                <p className="font-medium text-stone-700 text-sm">Current Time</p>
                <p className="text-xs text-stone-500">Pulsing dot + gradient line</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-lg bg-amber-100 flex items-center justify-center text-sm">➕</div>
              <div>
                <p className="font-medium text-stone-700 text-sm">Add Task CTA</p>
                <p className="text-xs text-stone-500">Appears in empty intervals</p>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Interactions</h3>
          <ul className="space-y-2 text-sm text-stone-600">
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Tap checkbox to complete
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Tap task pill to edit/view details
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Long press to drag & reschedule
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Swipe left for quick actions
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Pull down to refresh
            </li>
          </ul>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Swift Structure</h3>
          <div className="text-xs font-mono text-stone-600 bg-stone-50 rounded-xl p-3 space-y-1">
            <p className="text-stone-400">// Main view hierarchy</p>
            <p>VStack {'{'}</p>
            <p className="pl-3">HeaderView()</p>
            <p className="pl-3">WeekSelectorView()</p>
            <p className="pl-3">ScrollView {'{'}</p>
            <p className="pl-6">TimelineView(tasks)</p>
            <p className="pl-3">{'}'}</p>
            <p>{'}'}</p>
            <p className="text-stone-400 mt-2">// Task pill with duration</p>
            <p>struct TaskPill: View {'{'}</p>
            <p className="pl-3">var height: CGFloat {'{'}</p>
            <p className="pl-6">max(56, duration * hourHeight)</p>
            <p className="pl-3">{'}'}</p>
            <p>{'}'}</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Empty State Messages</h3>
          <div className="space-y-2 text-sm">
            <div className="flex items-center gap-2 text-stone-600">
              <span>💤</span>
              <span className="italic">"A well-spent interval."</span>
            </div>
            <div className="flex items-center gap-2 text-stone-600">
              <span>☕</span>
              <span className="italic">"Time for a break."</span>
            </div>
            <div className="flex items-center gap-2 text-stone-600">
              <span>⏰</span>
              <span className="italic">"Use Xh Xm, task approaching."</span>
            </div>
            <div className="flex items-center gap-2 text-stone-600">
              <span>🌟</span>
              <span className="italic">"Free time - you earned it!"</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DailyDetailView;
