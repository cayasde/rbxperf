const logger = require '@rbxperf/logger'
const test = require '@std/test'

test.suite('LoggerUnitSuite', function(suite)
	suite:case('should format messages with colors and prefixes', function(assert)
		local last_msg = ''
		logger.set_writer(function(msg)
			last_msg = msg
		end)

		logger.set_level('DEBUG')

		logger.info('Test info')
		assert.that(last_msg:match('%[INFO%]'), 'Missing INFO prefix')
		assert.that(last_msg:match('\27%[34m'), 'INFO log missing blue color')

		logger.warn('Test warn')
		assert.that(last_msg:match('%[WARN%]'), 'Missing WARN prefix')
		assert.that(last_msg:match('\27%[33m'), 'WARN log missing yellow color')

		logger.err('Test err')
		assert.that(last_msg:match('%[ERROR%]'), 'Missing ERROR prefix')
		assert.that(last_msg:match('\27%[31m'), 'ERROR log missing red color')

		logger.debug('Test debug')
		assert.that(last_msg:match('%[DEBUG%]'), 'Missing DEBUG prefix')
		assert.that(last_msg:match('\27%[36m'), 'DEBUG log missing cyan color')

		logger.success('Test success')
		assert.that(last_msg:match('%[SUCCESS%]'), 'Missing SUCCESS prefix')
		assert.that(last_msg:match('\27%[32m'), 'SUCCESS log missing green color')
	end)

	suite:case('should filter out logs below current level', function(assert)
		local logs = {}
		logger.set_writer(function(msg)
			table.insert(logs, msg)
		end)

		logger.set_level('WARN')

		logger.debug('Hidden debug')
		logger.info('Hidden info')
		logger.success('Hidden success')
		logger.warn('Visible warn')
		logger.err('Visible err')

		assert.eq(2, #logs)
		assert.that(logs[1]:match('Visible warn'))
		assert.that(logs[2]:match('Visible err'))
	end)
end)
