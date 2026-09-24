-- Public data returned by Fetch* methods.
export type CounterDesc = {
	CounterId: number,
	CounterName: string?,
	Parent: number,
	Sibling: number,
	FirstChild: number,
	Level: number,
}

export type CounterSample = {
	FrameId: number,
	Value: number,
}

export type FrameDesc = {
	FrameId: number,
	FrameAbsoluteId: number,
	TickStartCpu: number,
	TickEndCpu: number,
	TickStartGpu: number,
	TickEndGpu: number,
	LabelOffsetMin: number,
	LabelOffsetMax: number,
	IsPaused: boolean,
	IsIncomplete: boolean,
	ThreadLogs: { ThreadLogDescr },
}

export type GeneralInfo = {
	PlatformInfoJson: string?,
}

export type GlobalDesc = {
	TickToMsCpu: number,
	TickToMsGpu: number,
}

export type GroupDesc = {
	GroupId: number,
	GroupName: string?,
	Color: number,
	IsGpu: boolean,
}

export type ThreadDesc = {
	ThreadId: number,
	ThreadName: string?,
	BufferSize: number,
	IsGpu: boolean,
}

export type ThreadLogDescr = {
	ThreadId: number,
	LogEntriesNum: number,
	LogStartLocator: number,
	IsRemoved: boolean,
}

export type TimerDesc = {
	TimerId: number,
	TimerName: string?,
	GroupId: number,
	Color: number,
	IsUserTimer: boolean,
}

export type U64Sample = {
	FrameId: number,
	Value: number,
}

-- FlatBuffer views returned by Get* methods.
export type CounterDescView = {
	CounterId: (self: CounterDescView) -> number,
	CounterName: (self: CounterDescView) -> string?,
	Parent: (self: CounterDescView) -> number,
	Sibling: (self: CounterDescView) -> number,
	FirstChild: (self: CounterDescView) -> number,
	Level: (self: CounterDescView) -> number,
}

export type CounterSampleView = {
	FrameId: (self: CounterSampleView) -> number,
	Value: (self: CounterSampleView) -> number,
}

export type CustomData16bView = {
	Init: (self: CustomData16bView, buf: buffer, pos: number) -> (),
	B0: (self: CustomData16bView) -> number,
	B1: (self: CustomData16bView) -> number,
	B2: (self: CustomData16bView) -> number,
	B3: (self: CustomData16bView) -> number,
	B4: (self: CustomData16bView) -> number,
	B5: (self: CustomData16bView) -> number,
	B6: (self: CustomData16bView) -> number,
	B7: (self: CustomData16bView) -> number,
	B8: (self: CustomData16bView) -> number,
	B9: (self: CustomData16bView) -> number,
	B10: (self: CustomData16bView) -> number,
	B11: (self: CustomData16bView) -> number,
	B12: (self: CustomData16bView) -> number,
	B13: (self: CustomData16bView) -> number,
	B14: (self: CustomData16bView) -> number,
	B15: (self: CustomData16bView) -> number,
}

export type FrameDescView = {
	FrameId: (self: FrameDescView) -> number,
	FrameAbsoluteId: (self: FrameDescView) -> number,
	TickStartCpu: (self: FrameDescView) -> number,
	TickEndCpu: (self: FrameDescView) -> number,
	TickStartGpu: (self: FrameDescView) -> number,
	TickEndGpu: (self: FrameDescView) -> number,
	LabelOffsetMin: (self: FrameDescView) -> number,
	LabelOffsetMax: (self: FrameDescView) -> number,
	IsPaused: (self: FrameDescView) -> boolean,
	IsIncomplete: (self: FrameDescView) -> boolean,
	ThreadLogs: (self: FrameDescView, index: number) -> ThreadLogDescrView?,
	ThreadLogsLength: (self: FrameDescView) -> number,
}

export type GeneralInfoView = {
	PlatformInfoJson: (self: GeneralInfoView) -> string?,
}

export type GlobalDescView = {
	TickToMsCpu: (self: GlobalDescView) -> number,
	TickToMsGpu: (self: GlobalDescView) -> number,
}

export type GroupDescView = {
	GroupId: (self: GroupDescView) -> number,
	GroupName: (self: GroupDescView) -> string?,
	Color: (self: GroupDescView) -> number,
	IsGpu: (self: GroupDescView) -> boolean,
}

export type CounterIteratorStateView = {
	Started: (self: CounterIteratorStateView) -> boolean,
	Finished: (self: CounterIteratorStateView) -> boolean,
	CounterId: (self: CounterIteratorStateView) -> number,
	ParentId: (self: CounterIteratorStateView) -> number,
	Level: (self: CounterIteratorStateView) -> number,
	RelativeLevel: (self: CounterIteratorStateView) -> number,
	RootLevel: (self: CounterIteratorStateView) -> number,
	IndexInSiblings: (self: CounterIteratorStateView) -> number,
	IsLeaf: (self: CounterIteratorStateView) -> boolean,
	HierarchyChanged: (self: CounterIteratorStateView) -> boolean,
	CounterStackIsOverflowed: (self: CounterIteratorStateView) -> boolean,
}

export type LogIteratorStateView = {
	Started: (self: LogIteratorStateView) -> boolean,
	Finished: (self: LogIteratorStateView) -> boolean,
	ThreadStackDepth: (self: LogIteratorStateView) -> number,
	ThreadStackIsUnderflowed: (self: LogIteratorStateView) -> boolean,
	ThreadStackIsOverflowed: (self: LogIteratorStateView) -> boolean,
	ThreadStackWasOverflowed: (self: LogIteratorStateView) -> boolean,
	ThreadPrevTimestamp: (self: LogIteratorStateView) -> number,
	FrameId: (self: LogIteratorStateView) -> number,
	FrameAbsoluteId: (self: LogIteratorStateView) -> number,
	FrameDescLocator: (self: LogIteratorStateView) -> number,
	ThreadId: (self: LogIteratorStateView) -> number,
	IsGpuThread: (self: LogIteratorStateView) -> boolean,
	IsFrameStitching: (self: LogIteratorStateView) -> boolean,
	FrameChanged: (self: LogIteratorStateView) -> boolean,
	ThreadChanged: (self: LogIteratorStateView) -> boolean,
	EntryLocator: (self: LogIteratorStateView) -> number,
	TimerId: (self: LogIteratorStateView) -> number,
	Timestamp: (self: LogIteratorStateView) -> number,
	TimestampGpu: (self: LogIteratorStateView) -> number,
	EntryTypeRaw: (self: LogIteratorStateView) -> number,
	EventType: (self: LogIteratorStateView) -> number,
	IsUnknown: (self: LogIteratorStateView) -> boolean,
	IsEnter: (self: LogIteratorStateView) -> boolean,
	IsExit: (self: LogIteratorStateView) -> boolean,
	IsLabel: (self: LogIteratorStateView) -> boolean,
	IsEvent: (self: LogIteratorStateView) -> boolean,
	IsThreadFrameEnd: (self: LogIteratorStateView) -> boolean,
	IsFrameBoundary: (self: LogIteratorStateView) -> boolean,
}

export type LogIteratorThreadStackElementView = {
	EnterFrameId: (self: LogIteratorThreadStackElementView) -> number,
	EnterTimerId: (self: LogIteratorThreadStackElementView) -> number,
	EnterEntryLocator: (self: LogIteratorThreadStackElementView) -> number,
	EnterTimestamp: (self: LogIteratorThreadStackElementView) -> number,
	EnterTimestampFrameLocal: (self: LogIteratorThreadStackElementView) -> number,
	CustomData: (self: LogIteratorThreadStackElementView, object: CustomData16bView) -> CustomData16bView,
}

export type LogIteratorThreadStackStateView = {
	Depth: (self: LogIteratorThreadStackStateView) -> number,
	DepthAbsolute: (self: LogIteratorThreadStackStateView) -> number,
	DepthAbsoluteMin: (self: LogIteratorThreadStackStateView) -> number,
	IsUnderflowed: (self: LogIteratorThreadStackStateView) -> boolean,
	IsOverflowed: (self: LogIteratorThreadStackStateView) -> boolean,
	WasOverflowed: (self: LogIteratorThreadStackStateView) -> boolean,
}

export type ThreadDescView = {
	ThreadId: (self: ThreadDescView) -> number,
	ThreadName: (self: ThreadDescView) -> string?,
	BufferSize: (self: ThreadDescView) -> number,
	IsGpu: (self: ThreadDescView) -> boolean,
}

export type ThreadLogDescrView = {
	ThreadId: (self: ThreadLogDescrView) -> number,
	LogEntriesNum: (self: ThreadLogDescrView) -> number,
	LogStartLocator: (self: ThreadLogDescrView) -> number,
	IsRemoved: (self: ThreadLogDescrView) -> boolean,
}

export type TimerDescView = {
	TimerId: (self: TimerDescView) -> number,
	TimerName: (self: TimerDescView) -> string?,
	GroupId: (self: TimerDescView) -> number,
	Color: (self: TimerDescView) -> number,
	IsUserTimer: (self: TimerDescView) -> boolean,
}

export type U64SampleView = {
	FrameId: (self: U64SampleView) -> number,
	Value: (self: U64SampleView) -> number,
}

-- Input objects packed into FlatBuffers by iterator Configure methods.
export type CounterIteratorConfig = {
	RootCounterIds: { number }?,
}

export type LogIteratorConfig = {
	StartFrameId: number?,
	EndFrameId: number?,
	SkipGpuThreads: boolean?,
	SkipEvents: boolean?,
	SkipPausedFrames: boolean?,
	SkipFrameBoundaries: boolean?,
	SkipTimestampNormalization: boolean?,
	SkipThreadStackResume: boolean?,
	SkipThreadStackDepthSync: boolean?,
	EmitThreadFrameEnd: boolean?,
	ThreadIds: { number }?,
	GroupIds: { number }?,
	TimerIds: { number }?,
	SkipTimerIds: { number }?,
}

-- Array wrappers returned by Get* methods.
export type ArrayBase<T> = {
	Dispose: (self: ArrayBase<T>) -> (),
	Size: (self: ArrayBase<T>) -> number,
	FetchAll: (self: ArrayBase<T>) -> { T },
}

export type ScalarArray = ArrayBase<number> & {
	Get: (self: ScalarArray, index: number) -> number,
	Fetch: (self: ScalarArray, index: number) -> number,
}

export type TableArray<TView, TValue> = ArrayBase<TValue> & {
	Get: (self: TableArray<TView, TValue>, index: number) -> TView?,
	Fetch: (self: TableArray<TView, TValue>, index: number) -> TValue?,
}

export type StructArray<TView, TValue> = ArrayBase<TValue> & {
	Get: (self: StructArray<TView, TValue>, index: number) -> TView?,
	Fetch: (self: StructArray<TView, TValue>, index: number) -> TValue?,
}

export type CounterSampleArray = ArrayBase<CounterSample> & {
	Get: (self: CounterSampleArray, index: number) -> CounterSampleView?,
	Fetch: (self: CounterSampleArray, index: number) -> CounterSample?,
	GetSampleByFrameId: (self: CounterSampleArray, frameId: number) -> CounterSampleView?,
	FetchSampleByFrameId: (self: CounterSampleArray, frameId: number) -> CounterSample?,
	GetLastSample: (self: CounterSampleArray) -> CounterSampleView?,
	FetchLastSample: (self: CounterSampleArray) -> CounterSample?,
}

export type Control = {
	ptr: number,
	Global: Control?,
	new: (sessionPtr: number) -> Control,
	CaptureToBufferSync: (self: Control) -> buffer,
	EnableProfiler: (self: Control, enable: boolean) -> boolean,
	EnableCapture: (self: Control, enable: boolean) -> boolean,
	ShowUI: (self: Control, show: boolean) -> boolean,
	SetFrameLimit: (self: Control, num: number) -> boolean,
	UseControlChannel: (self: Control, use: boolean) -> boolean,
	IsBackendVersionCompatible: (self: Control) -> boolean,
	IsBackendAccessible: (self: Control) -> boolean,
	IsBackendReady: (self: Control) -> boolean,
	_syncIfGlobal: (self: Control) -> (),
}

export type LogIterator = {
	new: (sessionHandle: number) -> LogIterator,
	Dispose: (self: LogIterator) -> (),
	Configure: (self: LogIterator, configObj: LogIteratorConfig) -> (),
	Step: (self: LogIterator) -> boolean,
	Rewind: (self: LogIterator) -> (),
	RewindTo: (self: LogIterator, frameIdMin: number, frameIdMax: number) -> (),
	GetState: (self: LogIterator) -> LogIteratorStateView?,
	GetThreadStackState: (self: LogIterator, threadId: number) -> LogIteratorThreadStackStateView?,
	GetThreadStackElement: (
		self: LogIterator,
		threadId: number,
		stackLevel: number
	) -> LogIteratorThreadStackElementView?,
	GetCurrentThreadStackElement: (self: LogIterator, stackLevel: number) -> LogIteratorThreadStackElementView?,
}

export type CounterIterator = {
	new: (sessionHandle: number) -> CounterIterator,
	Dispose: (self: CounterIterator) -> (),
	Configure: (self: CounterIterator, configObj: CounterIteratorConfig) -> (),
	Step: (self: CounterIterator) -> boolean,
	Rewind: (self: CounterIterator) -> (),
	GetState: (self: CounterIterator) -> CounterIteratorStateView?,
	GetStackElement: (self: CounterIterator, stackLevel: number) -> number,
}

export type ExternalProvider = {
	open: (self: ExternalProvider) -> (),
	close: (self: ExternalProvider) -> (),
	getSize: (self: ExternalProvider) -> number,
	read: (
		self: ExternalProvider,
		dstBuf: buffer,
		dstOffset: number,
		blockId: number,
		offset: number,
		size: number
	) -> number,
}

type SessionSelf = {
	Control: Control,
}

type SessionMethods = {
	Dispose: (self: SessionSelf) -> (),
	SyncWithDataSource: (self: SessionSelf) -> boolean,
	SetSyncRequired: (self: SessionSelf) -> (),
	SetClearCacheOnSyncRequired: (self: SessionSelf) -> (),
	SyncIfRequired: (self: SessionSelf) -> (),
	IsValid: (self: SessionSelf) -> boolean,
	GetDataFormatVersion: (self: SessionSelf) -> number,
	WithDataLock: <T>(self: SessionSelf, callback: () -> T) -> (boolean, T?),
	ClearLuauCacheBucket: (self: SessionSelf, bucketIdx: number) -> (),
	_ClearCache: (self: SessionSelf) -> (),
	EnableObjectCache: (self: SessionSelf, enabled: boolean) -> (),
	ClearObjectCache: (self: SessionSelf) -> (),
	GetObjSize: (self: SessionSelf) -> number,

	GetGlobalDesc: (self: SessionSelf) -> GlobalDescView?,
	FetchGlobalDesc: (self: SessionSelf) -> GlobalDesc?,
	GetGeneralInfo: (self: SessionSelf) -> GeneralInfoView?,
	FetchGeneralInfo: (self: SessionSelf) -> GeneralInfo?,

	GetGroupIdMax: (self: SessionSelf) -> number,
	GetGroupDesc: (self: SessionSelf, groupId: number) -> GroupDescView?,
	FetchGroupDesc: (self: SessionSelf, groupId: number) -> GroupDesc?,

	GetTimerIds: (self: SessionSelf) -> ScalarArray,
	FetchTimerIds: (self: SessionSelf) -> { number },
	GetTimerDesc: (self: SessionSelf, timerId: number) -> TimerDescView?,
	FetchTimerDesc: (self: SessionSelf, timerId: number) -> TimerDesc?,

	GetCounterIds: (self: SessionSelf) -> ScalarArray,
	FetchCounterIds: (self: SessionSelf) -> { number },
	GetCounterDesc: (self: SessionSelf, counterId: number) -> CounterDescView?,
	FetchCounterDesc: (self: SessionSelf, counterId: number) -> CounterDesc?,
	GetCounterSamples: (self: SessionSelf, counterId: number) -> CounterSampleArray,
	FetchCounterSamples: (self: SessionSelf, counterId: number) -> { CounterSample },
	GetLastCounterSample: (self: SessionSelf, counterId: number) -> CounterSampleView?,
	FetchLastCounterSample: (self: SessionSelf, counterId: number) -> CounterSample?,

	GetThreadDesc: (self: SessionSelf, threadId: number) -> ThreadDescView?,
	FetchThreadDesc: (self: SessionSelf, threadId: number) -> ThreadDesc?,
	GetThreadIdGpu: (self: SessionSelf) -> number,
	GetThreadIds: (self: SessionSelf) -> ScalarArray,
	FetchThreadIds: (self: SessionSelf) -> { number },

	GetFrameIdMin: (self: SessionSelf) -> number,
	GetFrameIdMax: (self: SessionSelf) -> number,
	GetFrameDesc: (self: SessionSelf, frameId: number) -> FrameDescView?,
	FetchFrameDesc: (self: SessionSelf, frameId: number) -> FrameDesc?,

	GetPlaceIdSamples: (self: SessionSelf) -> StructArray<U64SampleView, U64Sample>,
	FetchPlaceIdSamples: (self: SessionSelf) -> { U64Sample },
	GetUtcTimestampSamples: (self: SessionSelf) -> StructArray<U64SampleView, U64Sample>,
	FetchUtcTimestampSamples: (self: SessionSelf) -> { U64Sample },

	CreateLogIterator: (self: SessionSelf) -> LogIterator,
	CreateCounterIterator: (self: SessionSelf) -> CounterIterator,

	_CallWithMask: (
		self: SessionSelf,
		func: (number, number, number) -> number,
		nameMask: string?,
		caseSensitive: boolean?
	) -> number,
	FindGroupId: (self: SessionSelf, nameMask: string, caseSensitive: boolean?) -> number,
	FindGroupIds: (self: SessionSelf, nameMask: string, caseSensitive: boolean?) -> { number },
	FindTimerId: (self: SessionSelf, nameMask: string, caseSensitive: boolean?) -> number,
	FindTimerIds: (self: SessionSelf, nameMask: string, caseSensitive: boolean?) -> { number },
	GetTimerIdsByGroupId: (self: SessionSelf, groupId: number) -> ScalarArray,
	FetchTimerIdsByGroupId: (self: SessionSelf, groupId: number) -> { number },
	GetTimerIdsByGroupNames: (self: SessionSelf, nameMask: string, caseSensitive: boolean?) -> ScalarArray,
	FetchTimerIdsByGroupNames: (self: SessionSelf, nameMask: string, caseSensitive: boolean?) -> { number },
	FindCounterId: (self: SessionSelf, nameMask: string, caseSensitive: boolean?) -> number,
	FindCounterIds: (self: SessionSelf, nameMask: string, caseSensitive: boolean?) -> { number },
	FindThreadId: (self: SessionSelf, nameMask: string, caseSensitive: boolean?) -> number,
	FindThreadIds: (self: SessionSelf, nameMask: string, caseSensitive: boolean?) -> { number },
}

export type Session = SessionSelf & SessionMethods

export type SessionClass = SessionMethods & {
	new: (ptr: number, id: number?) -> Session,
	OpenFromMem: (data: string | buffer) -> Session?,
	OpenFromExternalProvider: (io: ExternalProvider, cacheSize: number?) -> Session?,
	OpenFromBuffer: (b: buffer) -> Session?,
	OpenFromSlot: (id: number) -> Session?,
	OpenFromFile: (path: string, cacheSize: number?) -> Session?,
	OpenFromLiveData: () -> Session?,
}

export type Versions = {
	DataFormat: number,
	Library: number,
	new: () -> Versions,
}

export type GlobalControl = Control & {
	Global: Control,
}

export type RbxMP = {
	Control: GlobalControl,
	CounterIterator: CounterIterator,
	GetMemUsed: () -> number,
	IsCliMode: boolean,
	LogIterator: LogIterator,
	Session: SessionClass,
	Versions: Versions,
	init: () -> (),
}

export type LibMP = RbxMP

return require '@self/CLICK_ME_AND_SUMMON_150K_LINES_OF_LAG' :: RbxMP
