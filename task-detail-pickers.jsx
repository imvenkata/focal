import React, { useState, useRef, useEffect } from 'react';

const TaskDetailWithPickers = () => {
  const [taskTitle, setTaskTitle] = useState('Gym');
  const [isCompleted, setIsCompleted] = useState(false);
  const [activeSheet, setActiveSheet] = useState(null); // 'time', 'date', 'energy', null
  const [selectedTime, setSelectedTime] = useState('12:00 – 13:00');
  const [selectedDuration, setSelectedDuration] = useState('1h');
  const [selectedEnergy, setSelectedEnergy] = useState(1); // 0-4 scale
  const [selectedDate, setSelectedDate] = useState(new Date(2026, 0, 3));
  
  const timeScrollRef = useRef(null);
  const dateScrollRef = useRef(null);

  const colors = {
    coral: '#E8847C',
    coralLight: '#FDF2F1',
    coralDark: '#D4706A',
    sage: '#7BAE7F',
  };

  // Generate time slots
  const generateTimeSlots = () => {
    const slots = [];
    for (let hour = 0; hour < 24; hour++) {
      for (let min = 0; min < 60; min += 15) {
        const startHour = hour.toString().padStart(2, '0');
        const startMin = min.toString().padStart(2, '0');
        const endHour = ((hour + 1) % 24).toString().padStart(2, '0');
        slots.push(`${startHour}:${startMin} – ${endHour}:${startMin}`);
      }
    }
    return slots;
  };

  const timeSlots = generateTimeSlots();
  const durations = ['1', '15', '30', '45', '1h', '1.5h', '2h', '3h'];

  // Generate dates for picker
  const generateDates = () => {
    const dates = [];
    const today = new Date(2026, 0, 3);
    for (let i = -30; i < 60; i++) {
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      dates.push(date);
    }
    return dates;
  };

  const dates = generateDates();

  const energyLevels = [
    { icon: '🌿', label: 'Restful', desc: 'Low effort, recovery time' },
    { icon: '◎', label: 'Light', desc: 'Easy, minimal focus needed' },
    { icon: '🔥', label: 'Moderate', desc: 'Regular effort required' },
    { icon: '🔥🔥', label: 'High', desc: 'Demanding, full attention' },
    { icon: '🔥🔥🔥', label: 'Intense', desc: 'Maximum effort & focus' },
  ];

  const formatDate = (date) => {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return `${days[date.getDay()]}, ${date.getDate()} ${months[date.getMonth()]} ${date.getFullYear()}`;
  };

  const isToday = (date) => {
    const today = new Date(2026, 0, 3);
    return date.toDateString() === today.toDateString();
  };

  // Scroll to selected time on open
  useEffect(() => {
    if (activeSheet === 'time' && timeScrollRef.current) {
      const selectedIndex = timeSlots.findIndex(t => t === selectedTime);
      if (selectedIndex > -1) {
        timeScrollRef.current.scrollTop = selectedIndex * 44 - 88;
      }
    }
  }, [activeSheet]);

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-stone-100 via-stone-50 to-amber-50/20 p-8">
      {/* iPhone Frame */}
      <div className="relative w-[390px] h-[844px] bg-stone-900 rounded-[55px] p-3 shadow-2xl">
        <div className="relative w-full h-full bg-[#F8F7F4] rounded-[45px] overflow-hidden flex flex-col">
          
          {/* Dynamic Island */}
          <div className="absolute top-3 left-1/2 -translate-x-1/2 w-[126px] h-[37px] bg-black rounded-full z-50" />

          {/* Colored Header Section */}
          <div 
            className="relative pt-16 pb-6 px-5 flex-shrink-0"
            style={{ backgroundColor: colors.coralLight }}
          >
            {/* Timeline decoration */}
            <div 
              className="absolute left-8 top-0 bottom-0 w-0.5 border-l-2 border-dashed opacity-30"
              style={{ borderColor: colors.coral }}
            />

            {/* Top Actions */}
            <div className="flex justify-between items-start mb-6 relative z-10">
              <button 
                className="w-10 h-10 rounded-full flex items-center justify-center"
                style={{ backgroundColor: colors.coral }}
              >
                <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>

              <button 
                className="w-10 h-10 rounded-full flex items-center justify-center"
                style={{ backgroundColor: colors.coral }}
              >
                <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 24 24">
                  <circle cx="12" cy="6" r="2" />
                  <circle cx="12" cy="12" r="2" />
                  <circle cx="12" cy="18" r="2" />
                </svg>
              </button>
            </div>

            {/* Task Header */}
            <div className="flex items-start gap-4 relative z-10">
              <div className="relative">
                <div 
                  className="w-20 h-28 rounded-3xl flex items-center justify-center shadow-lg"
                  style={{ backgroundColor: colors.coral }}
                >
                  <span className="text-4xl">🏋️</span>
                </div>
                <button
                  className="absolute -bottom-2 -left-2 w-9 h-9 rounded-full bg-white shadow-md flex items-center justify-center border-2"
                  style={{ borderColor: colors.coral }}
                >
                  <span className="text-lg">🎨</span>
                </button>
              </div>

              <div className="flex-1 pt-2">
                <p className="text-sm font-medium mb-1 opacity-70" style={{ color: colors.coralDark }}>
                  {selectedTime} ({selectedDuration})
                </p>
                <input
                  type="text"
                  value={taskTitle}
                  onChange={(e) => setTaskTitle(e.target.value)}
                  className="text-2xl font-bold bg-transparent outline-none w-full"
                  style={{ color: colors.coralDark }}
                />
              </div>

              <button
                onClick={() => setIsCompleted(!isCompleted)}
                className={`w-8 h-8 rounded-full border-2 flex items-center justify-center mt-4 ${
                  isCompleted ? 'bg-emerald-500 border-emerald-500' : ''
                }`}
                style={{ borderColor: isCompleted ? undefined : colors.coralDark }}
              >
                {isCompleted && (
                  <svg className="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                  </svg>
                )}
              </button>
            </div>
          </div>

          {/* Details Card */}
          <div className="flex-1 bg-white rounded-t-[32px] -mt-4 shadow-[0_-4px_24px_rgba(0,0,0,0.08)] overflow-hidden flex flex-col relative z-20">
            <div className="flex-1 overflow-y-auto">
              {/* Date, Time, Alerts Section */}
              <div className="mx-5 mt-6 bg-stone-50 rounded-2xl overflow-hidden">
                {/* Date Row */}
                <button 
                  onClick={() => setActiveSheet('date')}
                  className="w-full flex items-center justify-between p-4 hover:bg-stone-100 transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ backgroundColor: `${colors.coral}20` }}>
                      <svg className="w-5 h-5" style={{ color: colors.coral }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                      </svg>
                    </div>
                    <span className="font-medium text-stone-800">{formatDate(selectedDate)}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-medium" style={{ color: colors.coral }}>
                      {isToday(selectedDate) ? 'Today' : ''}
                    </span>
                    <svg className="w-4 h-4 text-stone-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                </button>

                <div className="h-px bg-stone-200 mx-4" />

                {/* Time Row */}
                <button 
                  onClick={() => setActiveSheet('time')}
                  className="w-full flex items-center justify-between p-4 hover:bg-stone-100 transition-colors"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ backgroundColor: `${colors.coral}20` }}>
                      <svg className="w-5 h-5" style={{ color: colors.coral }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    </div>
                    <span className="font-medium text-stone-800">{selectedTime}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm text-stone-500">{selectedDuration}</span>
                    <svg className="w-4 h-4 text-stone-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                </button>

                <div className="h-px bg-stone-200 mx-4" />

                {/* Alerts Row */}
                <button className="w-full flex items-center justify-between p-4 hover:bg-stone-100 transition-colors">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ backgroundColor: `${colors.coral}20` }}>
                      <svg className="w-5 h-5" style={{ color: colors.coral }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                      </svg>
                    </div>
                    <span className="font-medium text-stone-800">3 Alerts</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm text-stone-500">Nudge</span>
                    <svg className="w-4 h-4 text-stone-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </div>
                </button>
              </div>

              {/* Repeat & Energy Pills */}
              <div className="flex gap-3 px-5 mt-4">
                <button className="flex-1 flex items-center justify-center gap-2 py-3 bg-stone-100 rounded-2xl hover:bg-stone-200 transition-colors">
                  <svg className="w-5 h-5 text-stone-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                  </svg>
                  <span className="font-medium text-stone-700">Repeat</span>
                  <span className="text-[10px] font-bold px-1.5 py-0.5 bg-amber-100 text-amber-700 rounded">PRO</span>
                </button>
                <button 
                  onClick={() => setActiveSheet('energy')}
                  className="flex-1 flex items-center justify-center gap-2 py-3 rounded-2xl transition-colors"
                  style={{ backgroundColor: `${colors.coral}15` }}
                >
                  <span className="text-lg">{energyLevels[selectedEnergy].icon}</span>
                  <span className="font-medium" style={{ color: colors.coral }}>Energy</span>
                </button>
              </div>

              {/* Subtasks */}
              <div className="px-5 mt-6">
                <div className="bg-stone-50 rounded-2xl p-4">
                  <div className="flex items-center gap-3">
                    <div className="w-6 h-6 rounded-lg border-2 border-dashed border-stone-300" />
                    <span className="text-stone-400">Add Subtask</span>
                  </div>
                </div>
              </div>

              {/* Notes */}
              <div className="px-5 mt-4 pb-6">
                <textarea
                  placeholder="Add notes, meeting links or phone numbers..."
                  className="w-full h-24 bg-stone-50 rounded-2xl p-4 text-stone-700 placeholder:text-stone-400 outline-none resize-none"
                />
              </div>
            </div>

            {/* Delete Button */}
            <div className="p-5 pt-2 border-t border-stone-100">
              <button className="w-full flex items-center justify-center gap-2 py-4 bg-red-50 hover:bg-red-100 rounded-2xl transition-colors">
                <svg className="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
                <span className="font-semibold text-red-500">Delete</span>
              </button>
            </div>

            <div className="flex justify-center pb-2">
              <div className="w-32 h-1 bg-stone-900 rounded-full" />
            </div>
          </div>

          {/* PICKER SHEETS */}
          
          {/* Time Picker Sheet */}
          {activeSheet === 'time' && (
            <div className="absolute inset-0 z-50 flex flex-col justify-end animate-fadeIn">
              <div className="absolute inset-0 bg-black/30" onClick={() => setActiveSheet(null)} />
              <div className="relative bg-white rounded-t-[28px] shadow-2xl animate-slideUp">
                {/* Header */}
                <div className="flex items-center justify-between p-4 border-b border-stone-100">
                  <h3 className="text-lg font-semibold text-stone-800">Time</h3>
                  <div className="flex items-center gap-2">
                    <button className="w-9 h-9 rounded-full bg-stone-100 flex items-center justify-center">
                      <svg className="w-5 h-5 text-stone-500" fill="currentColor" viewBox="0 0 24 24">
                        <circle cx="12" cy="6" r="2" />
                        <circle cx="12" cy="12" r="2" />
                        <circle cx="12" cy="18" r="2" />
                      </svg>
                    </button>
                    <button 
                      onClick={() => setActiveSheet(null)}
                      className="w-9 h-9 rounded-full bg-stone-100 flex items-center justify-center"
                    >
                      <svg className="w-5 h-5 text-stone-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    </button>
                  </div>
                </div>

                {/* Time Scroll Picker */}
                <div className="relative h-56 overflow-hidden">
                  {/* Gradient overlays */}
                  <div className="absolute top-0 left-0 right-0 h-16 bg-gradient-to-b from-white to-transparent z-10 pointer-events-none" />
                  <div className="absolute bottom-0 left-0 right-0 h-16 bg-gradient-to-t from-white to-transparent z-10 pointer-events-none" />
                  
                  {/* Selection indicator */}
                  <div className="absolute top-1/2 left-4 right-4 -translate-y-1/2 h-11 rounded-xl z-0" style={{ backgroundColor: `${colors.coral}15` }} />
                  
                  {/* Scrollable time list */}
                  <div 
                    ref={timeScrollRef}
                    className="h-full overflow-y-auto scrollbar-hide py-[88px] snap-y snap-mandatory"
                    style={{ scrollbarWidth: 'none', msOverflowStyle: 'none' }}
                  >
                    {timeSlots.map((time, index) => (
                      <button
                        key={index}
                        onClick={() => {
                          setSelectedTime(time);
                        }}
                        className={`w-full h-11 flex items-center justify-center snap-center transition-all ${
                          selectedTime === time 
                            ? 'font-semibold' 
                            : 'text-stone-400'
                        }`}
                        style={{ color: selectedTime === time ? colors.coral : undefined }}
                      >
                        {time}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Duration Section */}
                <div className="px-4 pb-6">
                  <div className="flex items-center justify-between mb-3">
                    <h4 className="font-semibold text-stone-800">Duration</h4>
                    <button className="w-8 h-8 rounded-full bg-stone-100 flex items-center justify-center">
                      <svg className="w-4 h-4 text-stone-500" fill="currentColor" viewBox="0 0 24 24">
                        <circle cx="12" cy="6" r="2" />
                        <circle cx="12" cy="12" r="2" />
                        <circle cx="12" cy="18" r="2" />
                      </svg>
                    </button>
                  </div>
                  <div className="flex gap-2 bg-stone-100 rounded-2xl p-1.5">
                    {durations.map((d) => (
                      <button
                        key={d}
                        onClick={() => setSelectedDuration(d)}
                        className={`flex-1 py-2.5 rounded-xl text-sm font-medium transition-all ${
                          selectedDuration === d 
                            ? 'bg-white shadow-sm' 
                            : 'text-stone-500 hover:text-stone-700'
                        }`}
                        style={{ color: selectedDuration === d ? colors.coral : undefined }}
                      >
                        {d}
                      </button>
                    ))}
                  </div>
                </div>

                <div className="flex justify-center pb-2">
                  <div className="w-32 h-1 bg-stone-300 rounded-full" />
                </div>
              </div>
            </div>
          )}

          {/* Date Picker Sheet */}
          {activeSheet === 'date' && (
            <div className="absolute inset-0 z-50 flex flex-col justify-end animate-fadeIn">
              <div className="absolute inset-0 bg-black/30" onClick={() => setActiveSheet(null)} />
              <div className="relative bg-white rounded-t-[28px] shadow-2xl animate-slideUp">
                {/* Header */}
                <div className="flex items-center justify-between p-4 border-b border-stone-100">
                  <h3 className="text-lg font-semibold text-stone-800">Date</h3>
                  <div className="flex items-center gap-2">
                    <button 
                      onClick={() => setSelectedDate(new Date(2026, 0, 3))}
                      className="px-3 py-1.5 rounded-lg text-sm font-medium"
                      style={{ backgroundColor: `${colors.coral}15`, color: colors.coral }}
                    >
                      Today
                    </button>
                    <button 
                      onClick={() => setActiveSheet(null)}
                      className="w-9 h-9 rounded-full bg-stone-100 flex items-center justify-center"
                    >
                      <svg className="w-5 h-5 text-stone-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    </button>
                  </div>
                </div>

                {/* Month Navigation */}
                <div className="flex items-center justify-between px-4 py-3">
                  <button className="w-9 h-9 rounded-full bg-stone-100 flex items-center justify-center">
                    <svg className="w-5 h-5 text-stone-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                    </svg>
                  </button>
                  <span className="font-semibold text-stone-800">January 2026</span>
                  <button className="w-9 h-9 rounded-full bg-stone-100 flex items-center justify-center">
                    <svg className="w-5 h-5 text-stone-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                  </button>
                </div>

                {/* Week Days Header */}
                <div className="grid grid-cols-7 px-4 pb-2">
                  {['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day, i) => (
                    <div key={i} className="text-center text-xs font-medium text-stone-400">
                      {day}
                    </div>
                  ))}
                </div>

                {/* Calendar Grid */}
                <div className="grid grid-cols-7 gap-1 px-4 pb-6">
                  {/* Empty cells for offset */}
                  {[...Array(3)].map((_, i) => (
                    <div key={`empty-${i}`} className="h-10" />
                  ))}
                  {/* Days of month */}
                  {[...Array(31)].map((_, i) => {
                    const day = i + 1;
                    const date = new Date(2026, 0, day);
                    const isSelected = selectedDate.getDate() === day && selectedDate.getMonth() === 0;
                    const today = day === 3;
                    
                    return (
                      <button
                        key={day}
                        onClick={() => setSelectedDate(date)}
                        className={`h-10 rounded-full flex items-center justify-center text-sm font-medium transition-all ${
                          isSelected 
                            ? 'text-white' 
                            : today 
                              ? 'text-amber-600 bg-amber-50'
                              : 'text-stone-700 hover:bg-stone-100'
                        }`}
                        style={{ backgroundColor: isSelected ? colors.coral : undefined }}
                      >
                        {day}
                      </button>
                    );
                  })}
                </div>

                <div className="flex justify-center pb-2">
                  <div className="w-32 h-1 bg-stone-300 rounded-full" />
                </div>
              </div>
            </div>
          )}

          {/* Energy Picker Sheet */}
          {activeSheet === 'energy' && (
            <div className="absolute inset-0 z-50 flex flex-col justify-end animate-fadeIn">
              <div className="absolute inset-0 bg-black/30" onClick={() => setActiveSheet(null)} />
              <div className="relative bg-white rounded-t-[28px] shadow-2xl animate-slideUp">
                {/* Header */}
                <div className="flex items-center justify-between p-4 border-b border-stone-100">
                  <h3 className="text-lg font-semibold text-stone-800">Energy</h3>
                  <div className="flex items-center gap-3">
                    <div className="flex items-center gap-1.5">
                      <span className="text-lg">🔥</span>
                      <span className="font-semibold" style={{ color: colors.coral }}>{selectedEnergy}</span>
                    </div>
                    <button 
                      onClick={() => setActiveSheet(null)}
                      className="w-9 h-9 rounded-full bg-stone-100 flex items-center justify-center"
                    >
                      <svg className="w-5 h-5 text-stone-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    </button>
                  </div>
                </div>

                {/* Energy Level Selector */}
                <div className="p-4">
                  <div className="flex gap-2 bg-stone-100 rounded-2xl p-1.5">
                    {energyLevels.map((level, index) => (
                      <button
                        key={index}
                        onClick={() => setSelectedEnergy(index)}
                        className={`flex-1 py-3 rounded-xl flex items-center justify-center transition-all ${
                          selectedEnergy === index 
                            ? 'bg-white shadow-sm' 
                            : ''
                        }`}
                        style={{ 
                          backgroundColor: selectedEnergy === index ? `${colors.coral}15` : undefined 
                        }}
                      >
                        {index === 0 ? (
                          <svg className={`w-6 h-6 ${selectedEnergy === index ? '' : 'text-stone-400'}`} style={{ color: selectedEnergy === index ? colors.sage : undefined }} fill="currentColor" viewBox="0 0 24 24">
                            <path d="M17 8C8 10 5.9 16.17 3.82 21.34l1.89.66l.95-2.3c.48.17.98.3 1.34.3C19 20 22 3 22 3c-1 2-8 2.25-13 3.25S2 11.5 2 13.5s1.75 3.75 1.75 3.75C7 8 17 8 17 8z"/>
                          </svg>
                        ) : index === 1 ? (
                          <div 
                            className={`w-6 h-6 rounded-full border-4 ${selectedEnergy === index ? '' : 'border-stone-300'}`}
                            style={{ borderColor: selectedEnergy === index ? colors.coral : undefined }}
                          />
                        ) : (
                          <div className="flex">
                            {[...Array(index - 1)].map((_, i) => (
                              <svg 
                                key={i} 
                                className={`w-5 h-5 -ml-1 first:ml-0 ${selectedEnergy === index ? '' : 'text-stone-400'}`}
                                style={{ color: selectedEnergy === index ? colors.coral : undefined }}
                                fill="currentColor" 
                                viewBox="0 0 24 24"
                              >
                                <path d="M12 23c-1.1 0-2-.9-2-2h4c0 1.1-.9 2-2 2zm4-4H8v-1l1-1v-3.5c0-2.3 1.2-4.3 3-5.3V5c0-.6.4-1 1-1s1 .4 1 1v1.2c1.8 1 3 3 3 5.3V15l1 1v1zm-4-14c-1.7 0-3 1.3-3 3h6c0-1.7-1.3-3-3-3z"/>
                              </svg>
                            ))}
                          </div>
                        )}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Description */}
                <div className="px-4 pb-6">
                  <div className="bg-stone-50 rounded-2xl p-4">
                    <div className="flex items-center gap-2 mb-2">
                      <span className="text-xl">{energyLevels[selectedEnergy].icon}</span>
                      <span className="font-semibold text-stone-800">{energyLevels[selectedEnergy].label}</span>
                    </div>
                    <p className="text-sm text-stone-500">
                      The energy monitor helps you get a better overview of what you can and cannot handle in terms of energy in a day, by calculating how much energy your schedule requires.
                    </p>
                  </div>
                </div>

                <div className="flex justify-center pb-2">
                  <div className="w-32 h-1 bg-stone-300 rounded-full" />
                </div>
              </div>
            </div>
          )}

        </div>
      </div>

      {/* Design Specs */}
      <div className="ml-12 max-w-md space-y-5">
        <div>
          <h2 className="text-2xl font-bold text-stone-800 mb-2">Picker Sheets</h2>
          <p className="text-stone-500">Time, Date & Energy selection</p>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-4">Time Picker</h3>
          <ul className="space-y-2 text-sm text-stone-600">
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-coral-500 rounded-full" style={{ backgroundColor: colors.coral }} />
              Scrollable time slots (15 min intervals)
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-coral-500 rounded-full" style={{ backgroundColor: colors.coral }} />
              Snap-to-center selection
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-coral-500 rounded-full" style={{ backgroundColor: colors.coral }} />
              Gradient fade at edges
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-coral-500 rounded-full" style={{ backgroundColor: colors.coral }} />
              Duration chips below
            </li>
          </ul>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-4">Date Picker</h3>
          <ul className="space-y-2 text-sm text-stone-600">
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: colors.coral }} />
              Calendar grid layout
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: colors.coral }} />
              Month navigation arrows
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: colors.coral }} />
              "Today" quick button
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: colors.coral }} />
              Selected day highlighted
            </li>
          </ul>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-4">Energy Picker</h3>
          <ul className="space-y-2 text-sm text-stone-600">
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: colors.coral }} />
              5 energy levels (0-4)
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: colors.coral }} />
              Visual icons: leaf → flames
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: colors.coral }} />
              Description card below
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: colors.coral }} />
              Current value in header
            </li>
          </ul>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Swift Implementation</h3>
          <div className="text-xs font-mono text-stone-600 bg-stone-50 rounded-xl p-3 space-y-1">
            <p className="text-stone-400">// Time picker with scroll</p>
            <p>ScrollViewReader {'{'} proxy in</p>
            <p className="pl-3">ScrollView {'{'}</p>
            <p className="pl-6">ForEach(timeSlots) {'{'} slot in</p>
            <p className="pl-9">TimeSlotRow(slot)</p>
            <p className="pl-9">.id(slot)</p>
            <p className="pl-6">{'}'}</p>
            <p className="pl-3">{'}'}</p>
            <p className="pl-3">.onAppear {'{'}</p>
            <p className="pl-6">proxy.scrollTo(selected)</p>
            <p className="pl-3">{'}'}</p>
            <p>{'}'}</p>
          </div>
        </div>

        <div className="bg-gradient-to-br from-amber-50 to-orange-50 rounded-2xl p-5 border border-amber-200/50">
          <h3 className="font-semibold text-amber-800 mb-2">💡 Interaction Tips</h3>
          <ul className="text-sm text-amber-700 space-y-1">
            <li>• Use UIScrollView with paging</li>
            <li>• Add haptic on snap selection</li>
            <li>• Sheet springs up from bottom</li>
            <li>• Tap outside to dismiss</li>
          </ul>
        </div>
      </div>

      <style jsx>{`
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes slideUp {
          from { transform: translateY(100%); }
          to { transform: translateY(0); }
        }
        .animate-fadeIn {
          animation: fadeIn 0.2s ease-out;
        }
        .animate-slideUp {
          animation: slideUp 0.3s ease-out;
        }
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
      `}</style>
    </div>
  );
};

export default TaskDetailWithPickers;
