function arg = parseFunctionArgument(val, type, defaultValue)
  % Validates an argument and returns the appropriate value. Uses the default
  % value if the passed value does not validate

  arg = defaultValue;

  switch lower(type)

    case {'logical', 'bool', 'boolean', 'onoff'}
      if islogical(val)
        arg = val;
        return
      end

      if iscellstr(val)
        val = val{:};
      end

      if ischar(val)
        logicalTrue  = {'yes', 'on',  'true' };
        logicalFalse = {'no',  'off', 'false'};
        switch lower(val)
          case logicalTrue
            arg = true;
            return
          case logicalFalse
            arg = false;
            return
        end
      end


    case {'file'}
      if iscellstr(val)
        val = val{:};
      end

      if isfile(val)
        arg = val;
        return
      end

    case {'folder', 'directory'}
      if iscellstr(val)
        val = val{:};
      end

      if isfolder(val)
        arg = val;
        return
      end

    otherwise

  end

end
