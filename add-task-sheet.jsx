import React, { useState } from 'react';

const AddTaskSheet = () => {
  const [taskTitle, setTaskTitle] = useState('');
  const [selectedColor, setSelectedColor] = useState(1);
  const [selectedIcon, setSelectedIcon] = useState(0);
  const [startTime, setStartTime] = useState('09:00');
  const [duration, setDuration] = useState(60);
  const [isRoutine, setIsRoutine] = useState(false);
  const [selectedDays, setSelectedDays] = useState([]);
  const [reminder, setReminder] = useState('15min');
  const [showIconPicker, setShowIconPicker] = useState(false);
  const [sheetState, setSheetState] = useState('expanded'); // 'peek', 'half', 'expanded'

  const colors = [
    { name: 'Coral', value: '#E8847C', light: '#FDF2F1' },
    { name: 'Sage', value: '#7BAE7F', light: '#F2F7F2' },
    { name: 'Sky', value: '#6BA3D6', light: '#F0F6FB' },
    { name: 'Lavender', value: '#9B8EC2', light: '#F5F3F9' },
    { name: 'Amber', value: '#D4A853', light: '#FBF7EE' },
    { name: 'Rose', value: '#C97B8E', light: '#FAF1F3' },
    { name: 'Slate', value: '#64748B', light: '#F4F5F7' },
    { name: 'Night', value: '#5C6B7A', light: '#F3F4F5' },
  ];

  const icons = [
    { emoji: '☀️', label: 'Morning' },
    { emoji: '🏋️', label: 'Workout' },
    { emoji: '💻', label: 'Work' },
    { emoji: '📚', label: 'Study' },
    { emoji: '🧘', label: 'Wellness' },
    { emoji: '🍽️', label: 'Meal' },
    { emoji: '🎨', label: 'Creative' },
    { emoji: '👥', label: 'Social' },
    { emoji: '🏃', label: 'Exercise' },
    { emoji: '🎵', label: 'Music' },
    { emoji: '✍️', label: 'Writing' },
    { emoji: '📧', label: 'Email' },
    { emoji: '🛒', label: 'Shopping' },
    { emoji: '🧹', label: 'Chores' },
    { emoji: '💊', label: 'Health' },
    { emoji: '🌙', label: 'Sleep' },
    { emoji: '☕', label: 'Break' },
    { emoji: '📞', label: 'Call' },
    { emoji: '✈️', label: 'Travel' },
    { emoji: '🎯', label: 'Focus' },
  ];

  const durations = [
    { label: '15m', value: 15 },
    { label: '30m', value: 30 },
    { label: '45m', value: 45 },
    { label: '1h', value: 60 },
    { label: '1.5h', value: 90 },
    { label: '2h', value: 120 },
    { label: '3h', value: 180 },
    { label: '4h', value: 240 },
  ];

  const reminderOptions = [
    { label: 'None', value: 'none' },
    { label: '5 min', value: '5min' },
    { label: '15 min', value: '15min' },
    { label: '30 min', value: '30min' },
    { label: '1 hour', value: '1hour' },
  ];

  const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  const toggleDay = (index) => {
    setSelectedDays(prev => 
      prev.includes(index) 
        ? prev.filter(d => d !== index)
        : [...prev, index]
    );
  };

  const currentColor = colors[selectedColor];

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-stone-100 via-stone-50 to-amber-50/20 p-8">
      {/* iPhone Frame */}
      <div className="relative w-[390px] h-[844px] bg-stone-900 rounded-[55px] p-3 shadow-2xl">
        <div className="relative w-full h-full bg-[#F8F7F4] rounded-[45px] overflow-hidden">
          
          {/* Dynamic Island */}
          <div className="absolute top-3 left-1/2 -translate-x-1/2 w-[126px] h-[37px] bg-black rounded-full z-50" />
          
          {/* Background (dimmed) */}
          <div className="absolute inset-0 bg-black/40 z-40" />

          {/* Sheet */}
          <div className="absolute bottom-0 left-0 right-0 bg-white rounded-t-[32px] z-50 shadow-2xl max-h-[92%] flex flex-col">
            
            {/* Handle */}
            <div className="flex justify-center pt-3 pb-1 flex-shrink-0">
              <div className="w-10 h-1 bg-stone-300 rounded-full" />
            </div>

            {/* Header */}
            <div className="flex items-center justify-between px-5 py-3 border-b border-stone-100 flex-shrink-0">
              <button className="text-stone-500 font-medium text-base hover:text-stone-700 transition-colors">
                Cancel
              </button>
              <h2 className="text-lg font-semibold text-stone-800">New Task</h2>
              <button 
                className={`font-semibold text-base transition-colors ${
                  taskTitle ? 'text-amber-600 hover:text-amber-700' : 'text-stone-300'
                }`}
                disabled={!taskTitle}
              >
                Save
              </button>
            </div>

            {/* Scrollable Content */}
            <div className="flex-1 overflow-y-auto">
              <div className="px-5 py-4 space-y-6">

                {/* Task Preview Card */}
                <div 
                  className="rounded-2xl p-4 transition-all duration-300"
                  style={{ backgroundColor: currentColor.light }}
                >
                  <div className="flex items-center gap-4">
                    <button
                      onClick={() => setShowIconPicker(!showIconPicker)}
                      className="w-14 h-14 rounded-2xl flex items-center justify-center shadow-sm transition-transform active:scale-95"
                      style={{ backgroundColor: currentColor.value }}
                    >
                      <span className="text-2xl">{icons[selectedIcon].emoji}</span>
                    </button>
                    <div className="flex-1">
                      <input
                        type="text"
                        value={taskTitle}
                        onChange={(e) => setTaskTitle(e.target.value)}
                        placeholder="Task name"
                        className="w-full text-lg font-semibold text-stone-800 bg-transparent outline-none placeholder:text-stone-400"
                        autoFocus
                      />
                      <p className="text-sm text-stone-500 mt-0.5">
                        {startTime} · {duration >= 60 ? `${duration / 60}h` : `${duration}m`}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Icon Picker (Expandable) */}
                {showIconPicker && (
                  <div className="bg-stone-50 rounded-2xl p-4 animate-slideDown">
                    <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-3">Choose Icon</p>
                    <div className="grid grid-cols-5 gap-2">
                      {icons.map((icon, index) => (
                        <button
                          key={index}
                          onClick={() => {
                            setSelectedIcon(index);
                            setShowIconPicker(false);
                          }}
                          className={`w-12 h-12 rounded-xl flex items-center justify-center transition-all ${
                            selectedIcon === index 
                              ? 'bg-white shadow-md scale-110' 
                              : 'hover:bg-white/50'
                          }`}
                        >
                          <span className="text-xl">{icon.emoji}</span>
                        </button>
                      ))}
                    </div>
                  </div>
                )}

                {/* Color Selection */}
                <div>
                  <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-3">Color</p>
                  <div className="flex gap-2 flex-wrap">
                    {colors.map((color, index) => (
                      <button
                        key={index}
                        onClick={() => setSelectedColor(index)}
                        className={`w-10 h-10 rounded-full transition-all ${
                          selectedColor === index 
                            ? 'ring-2 ring-offset-2 scale-110' 
                            : 'hover:scale-105'
                        }`}
                        style={{ 
                          backgroundColor: color.value,
                          ringColor: color.value
                        }}
                      >
                        {selectedColor === index && (
                          <svg className="w-5 h-5 text-white mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                          </svg>
                        )}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Date & Time */}
                <div>
                  <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-3">When</p>
                  <div className="bg-stone-50 rounded-2xl overflow-hidden">
                    {/* Date Row */}
                    <button className="w-full flex items-center justify-between p-4 hover:bg-stone-100 transition-colors">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-xl bg-amber-100 flex items-center justify-center">
                          <svg className="w-5 h-5 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                          </svg>
                        </div>
                        <span className="font-medium text-stone-800">Date</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className="text-stone-500">Today</span>
                        <svg className="w-4 h-4 text-stone-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                      </div>
                    </button>
                    
                    <div className="h-px bg-stone-200 mx-4" />
                    
                    {/* Time Row */}
                    <button className="w-full flex items-center justify-between p-4 hover:bg-stone-100 transition-colors">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-xl bg-sky-100 flex items-center justify-center">
                          <svg className="w-5 h-5 text-sky-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                          </svg>
                        </div>
                        <span className="font-medium text-stone-800">Start Time</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <span className="text-stone-500">{startTime}</span>
                        <svg className="w-4 h-4 text-stone-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                      </div>
                    </button>
                  </div>
                </div>

                {/* Duration */}
                <div>
                  <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-3">Duration</p>
                  <div className="flex gap-2 flex-wrap">
                    {durations.map((d) => (
                      <button
                        key={d.value}
                        onClick={() => setDuration(d.value)}
                        className={`px-4 py-2 rounded-xl font-medium text-sm transition-all ${
                          duration === d.value 
                            ? 'text-white shadow-md' 
                            : 'bg-stone-100 text-stone-600 hover:bg-stone-200'
                        }`}
                        style={{ 
                          backgroundColor: duration === d.value ? currentColor.value : undefined 
                        }}
                      >
                        {d.label}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Repeat / Routine */}
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide">Repeat</p>
                    <button
                      onClick={() => setIsRoutine(!isRoutine)}
                      className={`w-12 h-7 rounded-full transition-all ${
                        isRoutine ? '' : 'bg-stone-200'
                      }`}
                      style={{ backgroundColor: isRoutine ? currentColor.value : undefined }}
                    >
                      <div className={`w-5 h-5 rounded-full bg-white shadow-sm transition-transform ${
                        isRoutine ? 'translate-x-6' : 'translate-x-1'
                      }`} />
                    </button>
                  </div>
                  
                  {isRoutine && (
                    <div className="bg-stone-50 rounded-2xl p-4 animate-slideDown">
                      <p className="text-xs text-stone-500 mb-3">Repeat on</p>
                      <div className="flex gap-2">
                        {weekDays.map((day, index) => (
                          <button
                            key={index}
                            onClick={() => toggleDay(index)}
                            className={`w-9 h-9 rounded-full font-semibold text-sm transition-all ${
                              selectedDays.includes(index)
                                ? 'text-white shadow-md'
                                : 'bg-white text-stone-600 hover:bg-stone-100'
                            }`}
                            style={{ 
                              backgroundColor: selectedDays.includes(index) ? currentColor.value : undefined 
                            }}
                          >
                            {day}
                          </button>
                        ))}
                      </div>
                      <div className="flex gap-2 mt-3">
                        <button 
                          onClick={() => setSelectedDays([0, 1, 2, 3, 4])}
                          className="px-3 py-1.5 rounded-lg text-xs font-medium bg-white text-stone-600 hover:bg-stone-100 transition-colors"
                        >
                          Weekdays
                        </button>
                        <button 
                          onClick={() => setSelectedDays([5, 6])}
                          className="px-3 py-1.5 rounded-lg text-xs font-medium bg-white text-stone-600 hover:bg-stone-100 transition-colors"
                        >
                          Weekends
                        </button>
                        <button 
                          onClick={() => setSelectedDays([0, 1, 2, 3, 4, 5, 6])}
                          className="px-3 py-1.5 rounded-lg text-xs font-medium bg-white text-stone-600 hover:bg-stone-100 transition-colors"
                        >
                          Every day
                        </button>
                      </div>
                    </div>
                  )}
                </div>

                {/* Reminder */}
                <div>
                  <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-3">Reminder</p>
                  <div className="flex gap-2 flex-wrap">
                    {reminderOptions.map((r) => (
                      <button
                        key={r.value}
                        onClick={() => setReminder(r.value)}
                        className={`px-4 py-2 rounded-xl font-medium text-sm transition-all ${
                          reminder === r.value 
                            ? 'text-white shadow-md' 
                            : 'bg-stone-100 text-stone-600 hover:bg-stone-200'
                        }`}
                        style={{ 
                          backgroundColor: reminder === r.value ? currentColor.value : undefined 
                        }}
                      >
                        {r.label}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Notes */}
                <div>
                  <p className="text-xs font-semibold text-stone-500 uppercase tracking-wide mb-3">Notes</p>
                  <textarea
                    placeholder="Add notes or details..."
                    className="w-full h-24 bg-stone-50 rounded-2xl p-4 text-stone-700 placeholder:text-stone-400 outline-none resize-none focus:ring-2 transition-all"
                    style={{ focusRingColor: currentColor.value }}
                  />
                </div>

                {/* Bottom padding for scroll */}
                <div className="h-8" />
              </div>
            </div>

            {/* Bottom Action */}
            <div className="flex-shrink-0 p-5 pt-3 border-t border-stone-100 bg-white">
              <button 
                className={`w-full py-4 rounded-2xl font-semibold text-white text-base transition-all active:scale-[0.98] ${
                  taskTitle ? 'shadow-lg' : 'opacity-50'
                }`}
                style={{ 
                  backgroundColor: currentColor.value,
                  boxShadow: taskTitle ? `0 8px 24px ${currentColor.value}40` : undefined
                }}
                disabled={!taskTitle}
              >
                Create Task
              </button>
            </div>

            {/* Home Indicator */}
            <div className="flex justify-center pb-2">
              <div className="w-32 h-1 bg-stone-900 rounded-full" />
            </div>
          </div>
        </div>
      </div>

      {/* Design Specs */}
      <div className="ml-12 max-w-md space-y-5">
        <div>
          <h2 className="text-2xl font-bold text-stone-800 mb-2">Add Task Sheet</h2>
          <p className="text-stone-500">Bottom sheet with all task options</p>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-4">Form Fields</h3>
          <div className="space-y-3">
            {[
              { icon: '✏️', label: 'Task Name', desc: 'Required, auto-focus on open' },
              { icon: '🎨', label: 'Icon & Color', desc: '20 icons, 8 colors' },
              { icon: '📅', label: 'Date', desc: 'Native iOS date picker' },
              { icon: '⏰', label: 'Start Time', desc: 'Time wheel picker' },
              { icon: '⏱️', label: 'Duration', desc: 'Preset chips: 15m–4h' },
              { icon: '🔄', label: 'Repeat', desc: 'Toggle + day selector' },
              { icon: '🔔', label: 'Reminder', desc: 'Before task notification' },
              { icon: '📝', label: 'Notes', desc: 'Optional text area' },
            ].map((field, i) => (
              <div key={i} className="flex items-start gap-3">
                <span className="text-lg">{field.icon}</span>
                <div>
                  <p className="font-medium text-stone-700 text-sm">{field.label}</p>
                  <p className="text-xs text-stone-500">{field.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Sheet Behavior</h3>
          <ul className="space-y-2 text-sm text-stone-600">
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Drag handle to resize (half/full)
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Swipe down to dismiss
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Tap outside to dismiss
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Keyboard avoidance built-in
            </li>
            <li className="flex items-center gap-2">
              <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full" />
              Haptic on color/icon select
            </li>
          </ul>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Swift Implementation</h3>
          <div className="text-xs font-mono text-stone-600 bg-stone-50 rounded-xl p-3 space-y-1">
            <p className="text-stone-400">// Present as sheet</p>
            <p>.sheet(isPresented: $showAddTask) {'{'}</p>
            <p className="pl-3">AddTaskView()</p>
            <p className="pl-6">.presentationDetents([.medium, .large])</p>
            <p className="pl-6">.presentationDragIndicator(.visible)</p>
            <p className="pl-6">.interactiveDismissDisabled(hasChanges)</p>
            <p>{'}'}</p>
            <p></p>
            <p className="text-stone-400">// Color picker with haptic</p>
            <p>Button {'{'}</p>
            <p className="pl-3">selectedColor = color</p>
            <p className="pl-3">UIImpactFeedbackGenerator(style: .light)</p>
            <p className="pl-6">.impactOccurred()</p>
            <p>{'}'}</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl p-5 shadow-sm border border-stone-200">
          <h3 className="font-semibold text-stone-800 mb-3">Task Model</h3>
          <div className="text-xs font-mono text-stone-600 bg-stone-50 rounded-xl p-3 space-y-1">
            <p>struct Task: Identifiable {'{'}</p>
            <p className="pl-3">let id: UUID</p>
            <p className="pl-3">var title: String</p>
            <p className="pl-3">var icon: String</p>
            <p className="pl-3">var color: Color</p>
            <p className="pl-3">var startTime: Date</p>
            <p className="pl-3">var duration: TimeInterval</p>
            <p className="pl-3">var isRoutine: Bool</p>
            <p className="pl-3">var repeatDays: Set&lt;Weekday&gt;</p>
            <p className="pl-3">var reminder: ReminderOption?</p>
            <p className="pl-3">var notes: String?</p>
            <p className="pl-3">var isCompleted: Bool</p>
            <p>{'}'}</p>
          </div>
        </div>

        <div className="bg-gradient-to-br from-amber-50 to-orange-50 rounded-2xl p-5 border border-amber-200/50">
          <h3 className="font-semibold text-amber-800 mb-2">💡 UX Tips</h3>
          <ul className="text-sm text-amber-700 space-y-1">
            <li>• Auto-suggest icons based on task name</li>
            <li>• Remember last used color preference</li>
            <li>• Smart time suggestions (after last task)</li>
            <li>• "Quick add" mode for minimal input</li>
          </ul>
        </div>
      </div>

      <style jsx>{`
        @keyframes slideDown {
          from { opacity: 0; transform: translateY(-10px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .animate-slideDown {
          animation: slideDown 0.2s ease-out;
        }
      `}</style>
    </div>
  );
};

export default AddTaskSheet;
